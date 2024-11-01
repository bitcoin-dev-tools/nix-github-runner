{ config, lib, pkgs, ... }:

{
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
      # Only run if channels aren't set up
      if [ ! -e "/nix/var/nix/profiles/per-user/root/channels" ]; then
        ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixos-unstable nixos
        ${pkgs.nix}/bin/nix-channel --update
      fi
    '';
  };
}
