{ config, pkgs, lib, ... }:
let
  runner_token = builtins.getEnv "RUNNER_TOKEN";
in {
  virtualisation.docker.enable = true;

  users.groups = {
    github-runner = {};
    perf = {};
  };

  users.users.github-runner = {
    isNormalUser = true;
    group = "github-runner";
    extraGroups = [ "docker" "perf" ];
  };

  systemd.tmpfiles.rules = [
    "d /data/runner_workspace 0755 github-runner github-runner -"
    "d /data/ccache 0755 github-runner github-runner -"
  ];

  environment.etc.gh_token.text = runner_token;

  systemd.services.github-runner-ax52 = {
    startLimitIntervalSec = 300;
    startLimitBurst = 3;
  };

  services.github-runners.ax52 = {
    enable = true;
    user = "github-runner";
    url = "https://github.com/bitcoin-dev-tools";
    tokenFile = "/etc/gh_token";
    ephemeral = true;
    workDir = "/data/runner_workspace";
    replace = true;
    extraPackages = with pkgs; [
      config.virtualisation.docker.package
      ccache
    ];
    serviceOverrides = {
      ProtectHome = false;
      ReadWritePaths = [
        "/data/ccache"
        "/data/runner_workspace"
      ];
      AmbientCapabilities = [ "CAP_SYS_RAWIO" ];
      CapabilityBoundingSet = [ "CAP_SYS_RAWIO" ];
      # Rate limit unsucessful restarts
      StartLimitBurst = 3;
      StartLimitIntervalSec = 300;
      # Restart on any exit code
      RestartForceExitStatus = [ 0 1 2 ];
      # Override the default succeed-exit-codes to ensure restarts happen
      SuccessExitStatus = [ 0 1 2 ];
    };
  };
}
