{ ... }: {
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ../../modules/core
    ../../modules/services
    ../../modules/users
    ../../modules/tools
  ];

  system.activationScripts.setDataPermissions = ''
    chown satoshi:users /data
  '';
}
