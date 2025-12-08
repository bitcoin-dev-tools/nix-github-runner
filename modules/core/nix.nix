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

  # Allow nix-daemon to use all CPUs including isolated ones (isolcpus=2-15)
  # AllowedCPUs sets cgroup permission, but isolcpus requires explicit affinity
  # ExecStart with taskset sets affinity for daemon AND all forked children
  systemd.services.nix-daemon.serviceConfig = {
    AllowedCPUs = "0-15";
    ExecStart = [
      ""  # Clear the default ExecStart
      "${pkgs.util-linux}/bin/taskset -c 0-15 ${pkgs.nix}/bin/nix-daemon"
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
