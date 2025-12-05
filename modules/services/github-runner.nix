{ config, pkgs, ... }:
let runner_token = builtins.getEnv "RUNNER_TOKEN";
in {
  imports = [ ./github-runner-definition/module.nix ];
  virtualisation.docker.enable = true;

  # Setuid wrapper to allow dropping page cache without full sudo access
  security.wrappers.drop-caches = {
    source = "${pkgs.writeShellScript "drop-caches" ''
      sync
      echo 3 > /proc/sys/vm/drop_caches
    ''}";
    owner = "root";
    group = "root";
    setuid = true;
  };

  users.groups.perf = { };

  users.users.github-runner = {
    isNormalUser = true;
    extraGroups = [ "docker" "perf" "wheel" ];
    home = "/home/github-runner";
    shell = pkgs.bash;
  };

  systemd.tmpfiles.rules = [
    "d /data/runner_workspace 0755 github-runner users -"
    "d /data/ccache 0755 github-runner users -"
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
        "/data/ccache"
        "/data/runner_workspace"
        "/data/SOURCES_PATH"
        "/data/BASE_CACHE"
        "/gnu"
        "/var/guix"
        "/tmp"
        "/proc"
        "/sys"
      ];

      Environment =
        [ "SOURCES_PATH=/data/SOURCES_PATH" "BASE_CACHE=/data/BASE_CACHE" ];

      # Override restart defaults
      RestartForceExitStatus = [ 0 1 2 ];
      StartLimitBurst = 3;
      StartLimitIntervalSec = 300;
      SuccessExitStatus = [ 0 1 2 ];

      # Add capability for managing process priorities using chrt
      AmbientCapabilities = [ "CAP_SYS_NICE" "CAP_DAC_OVERRIDE" ];
      CapabilityBoundingSet = [ "CAP_SYS_NICE" "CAP_DAC_OVERRIDE" ];
    };
  };
}
