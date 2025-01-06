{ modulesPath, lib, pkgs, ... }: {
  system.activationScripts.setDataPermissions = ''
    chown satoshi:users /data
  '';
}
