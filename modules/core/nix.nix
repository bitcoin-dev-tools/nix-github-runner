{ pkgs, ... }:
{
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

  # Force nix-daemon to use ONLY isolated CPUs (2-15)
  # With isolcpus=2-15, including non-isolated cores (0-1) causes scheduler to prefer only those
  # By restricting to 2-15 only, scheduler is forced to use the isolated cores
  systemd.services.nix-daemon.serviceConfig = {
    AllowedCPUs = "2-15";
    ExecStart = [
      ""  # Clear the default ExecStart
      "${pkgs.util-linux}/bin/taskset -c 2-15 ${pkgs.nix}/bin/nix-daemon"
    ];
  };

  systemd.services.setup-nix-channels = {
    description = "Setup Nix channels";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    unitConfig = {
      RefuseManualStart = true;
      RemainAfterExit = true;
    };

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };

    script = ''
      if [ ! -e "/nix/var/nix/profiles/per-user/root/channels" ]; then
        ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixos-unstable nixos
        ${pkgs.nix}/bin/nix-channel --update
      fi
    '';
  };
}
