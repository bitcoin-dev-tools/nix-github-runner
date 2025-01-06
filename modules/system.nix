{ config, lib, pkgs, ... }:
let
  runner_token = builtins.getEnv "RUNNER_TOKEN";
in
{
  time.timeZone = "UTC";

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
        "configurable-impure-env"
      ];
    };
  };

  services = {
    journald.extraConfig = ''
      SystemMaxUse=500M
      MaxRetentionSec=1month
    '';
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
    };
    etc = {
      gh_token = {
        text = runner_token;
      };
    };

  };

  systemd.tmpfiles.rules = [
    "d /data/runner_workspace 0755 github-runner github-runner -"
    "d /data/ccache 0755 github-runner github-runner -"
  ];

  # Github Actions Runner config
  virtualisation.docker.enable = true;
  users.groups.github-runner = {};
  users.users.github-runner = {
    isNormalUser = true;
    group = "github-runner";
    extraGroups = [ "docker" ];
  };
  services.github-runners.ax52.enable = true;
  services.github-runners.ax52.user = "github-runner";
  services.github-runners.ax52.url = "https://github.com/bitcoin-dev-tools";
  services.github-runners.ax52.tokenFile = "/etc/gh_token";
  services.github-runners.ax52.ephemeral = true; # This requires that the token be a PAT with org:self-hosted-runner permsissions
  services.github-runners.ax52.workDir = "/data/runner_workspace";
  services.github-runners.ax52.extraPackages = with pkgs; [ config.virtualisation.docker.package ccache ];
  services.github-runners.ax52.serviceOverrides = {
    ProtectHome = false;
    ReadWritePaths = [ "/data/ccache" "/data/runner_workspace" ];
  };
  # End Github Actions Runner config

  system.stateVersion = "unstable";
}
