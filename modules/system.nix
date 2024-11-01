{ config, lib, pkgs, ... }:
let
  runner_token = builtins.getEnv "RUNNER_TOKEN";
in
{
  time.timeZone = "UTC";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
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

  # Github Actions Runner config
  virtualisation.docker.enable = true;
  users.users.github-runner = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
  };
  services.github-runners.ax52.enable = true;
  services.github-runners.ax52.user = "github-runner";
  services.github-runners.ax52.url = "https://github.com/bitcoin-dev-tools";
  services.github-runners.ax52.tokenFile = "/etc/gh_token";
  services.github-runners.ax52.extraPackages = with pkgs; [ config.virtualisation.docker.package ];
  # End Github Actions Runner config

  system.stateVersion = "unstable";
}
