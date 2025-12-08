{ config, pkgs, ... }:
let
  runner_token = builtins.getEnv "RUNNER_TOKEN";
in
{
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

  environment.etc.gh_token.text = runner_token;

  services.github-runners.ax52 = {
    enable = true;
    user = "github-runner";
    url = "https://github.com/bitcoin-dev-tools";
    tokenFile = "/etc/gh_token";
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
      StartLimitBurst = 3;
      StartLimitIntervalSec = 300;
      SuccessExitStatus = [
        0
        1
        2
      ];

      # Add capability for managing process priorities using chrt
      AmbientCapabilities = [
        "CAP_SYS_NICE"
        "CAP_DAC_OVERRIDE"
      ];
      CapabilityBoundingSet = [
        "CAP_SYS_NICE"
        "CAP_DAC_OVERRIDE"
      ];
    };
  };
}
