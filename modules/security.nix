{ config, lib, pkgs, ... }:
{
  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowPing = true;
  };

  # SSH hardening
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "yes";
      AllowTcpForwarding = "no";
      X11Forwarding = false;
    };
  };

  # System security
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "24h";
  };
}
