{ config, pkgs, ... }:
let runner_token = builtins.getEnv "RUNNER_TOKEN";
in {
  virtualisation.docker.enable = true;

  users.groups.github-runner = { };
  users.users.github-runner = {
    isNormalUser = true;
    group = "github-runner";
    extraGroups = [ "docker" ];
  };

  systemd.tmpfiles.rules = [
    "d /data/runner_workspace 0755 github-runner github-runner -"
    "d /data/ccache 0755 github-runner github-runner -"
  ];

  environment.etc = { gh_token = { text = runner_token; }; };

  services.github-runners.ax52 = {
    enable = true;
    user = "github-runner";
    url = "https://github.com/bitcoin-dev-tools";
    tokenFile = "/etc/gh_token";
    ephemeral = true;
    workDir = "/data/runner_workspace";
    extraPackages = with pkgs; [ config.virtualisation.docker.package ccache ];
    serviceOverrides = {
      ProtectHome = false;
      ReadWritePaths = [ "/data/ccache" "/data/runner_workspace" ];
    };
  };
}
