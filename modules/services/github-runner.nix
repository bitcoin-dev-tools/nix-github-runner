{ config, pkgs, ... }:
{
  sops.secrets.runner_token = {
    sopsFile = ../../secrets/default.yaml;
    owner = "github-runner";
    mode = "0400";
  };

  imports = [ ./github-runner-definition/module.nix ];
  virtualisation.docker.enable = true;

  # Allow nix sandbox to access ccache
  nix.settings.extra-sandbox-paths = [ "/nix/var/cache/ccache" ];

  # Wrapper to allow dropping page cache without full sudo access
  # Must be a compiled bin as Linux ignores setuid on interpreted scripts
  security.wrappers.drop-caches = {
    source = "${
      pkgs.stdenv.mkDerivation {
        name = "drop-caches";
        dontUnpack = true;
        buildPhase = ''
          $CC -x c -o drop-caches - <<'EOF'
          #include <stdio.h>
          #include <unistd.h>
          int main(void) {
            sync();
            FILE *f = fopen("/proc/sys/vm/drop_caches", "w");
            if (!f) { perror("drop_caches"); return 1; }
            fprintf(f, "3\n");
            fclose(f);
            return 0;
          }
          EOF
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp drop-caches $out/bin/
        '';
      }
    }/bin/drop-caches";
    owner = "root";
    group = "root";
    setuid = true;
  };

  # Wrapper to allow fstrim without full sudo access
  # Ensures consistent SSD write performance across benchmark runs
  # Uses FITRIM ioctl directly (like drop-caches) since execl drops setuid
  security.wrappers.fstrim = {
    source = "${
      pkgs.stdenv.mkDerivation {
        name = "fstrim";
        dontUnpack = true;
        buildPhase = ''
          $CC -x c -o fstrim-wrapper - <<'EOF'
          #include <stdio.h>
          #include <unistd.h>
          #include <fcntl.h>
          #include <sys/ioctl.h>
          #include <linux/fs.h>
          int main(int argc, char *argv[]) {
            if (argc != 2) {
              fprintf(stderr, "Usage: fstrim <path>\n");
              return 1;
            }
            int fd = open(argv[1], O_RDONLY);
            if (fd < 0) { perror(argv[1]); return 1; }
            struct fstrim_range range = { .start = 0, .len = (unsigned long long)-1, .minlen = 0 };
            if (ioctl(fd, FITRIM, &range)) { perror("FITRIM"); close(fd); return 1; }
            close(fd);
            return 0;
          }
          EOF
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp fstrim-wrapper $out/bin/fstrim
        '';
      }
    }/bin/fstrim";
    owner = "root";
    group = "root";
    setuid = true;
  };

  # Lightweight system metrics logger for correlating with benchmark runs
  systemd.services.bench-monitor = {
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ coreutils gawk ];
    script = ''
      # CPU temp: find k10temp or first available hwmon
      temp="N/A"
      for f in /sys/class/hwmon/hwmon*/temp1_input; do
        if [ -r "$f" ]; then temp=$(cat "$f"); break; fi
      done

      # NVMe disk I/O (nvme1n1 = /data)
      disk=$(awk '/nvme1n1 / {print "rd="$4" wr="$8}' /proc/diskstats)

      # Network RX/TX bytes (sum all physical interfaces)
      net=$(awk '/eth|enp|eno/ {rx+=$2; tx+=$10} END {print "rx="rx" tx="tx}' /proc/net/dev)

      echo "$(date -uIs) cpu=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq) temp=$temp load=$(cat /proc/loadavg) $disk $net" >> /data/system-metrics.log
    '';
  };
  systemd.timers.bench-monitor = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "*:*:0/10";
  };

  users.groups.perf = { };

  users.users.github-runner = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "perf"
      "wheel"
    ];
    home = "/home/github-runner";
    shell = pkgs.bash;
  };

  systemd.tmpfiles.rules = [
    "d /data/runner_workspace 0755 github-runner users -"
    "d /nix/var/cache/ccache 0770 github-runner nixbld -"
    "d /data/SOURCES_PATH 0755 github-runner users -"
    "d /data/BASE_CACHE 0755 github-runner users -"
  ];

  services.github-runners.ax52 = {
    enable = true;
    user = "github-runner";
    url = "https://github.com/bitcoin-dev-tools";
    tokenFile = config.sops.secrets.runner_token.path;
    ephemeral = true;
    workDir = "/data/runner_workspace";
    replace = true;
    # Use github-runner from unstable otherwise it GH deprecates it too fast :(
    package = pkgs.github-runner-unstable;
    extraPackages = with pkgs; [
      config.virtualisation.docker.package
      ccache
      guix
    ];
    serviceOverrides = {
      ReadWritePaths = [
        "/home/github-runner"
        "/nix/var/cache/ccache"
        "/data/runner_workspace"
        "/data/SOURCES_PATH"
        "/data/BASE_CACHE"
        "/gnu"
        "/var/guix"
        "/tmp"
        "/proc"
        "/sys"
      ];

      Environment = [
        "SOURCES_PATH=/data/SOURCES_PATH"
        "BASE_CACHE=/data/BASE_CACHE"
      ];

      # Override restart defaults
      RestartForceExitStatus = [
        0
        1
        2
      ];
      SuccessExitStatus = [
        0
        1
        2
      ];

      AmbientCapabilities = [
        "CAP_SYS_NICE"
        "CAP_DAC_OVERRIDE"
      ];
      CapabilityBoundingSet = [
        "CAP_SYS_NICE"
        "CAP_DAC_OVERRIDE"
        "CAP_SYS_ADMIN"  # for fstrim suid wrapper (FITRIM ioctl)
      ];
    };
    unitOverrides = {
      StartLimitBurst = 3;
      StartLimitIntervalSec = 300;
    };
  };
}
