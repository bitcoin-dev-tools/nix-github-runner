{ ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "yes";
      AllowTcpForwarding = "no";
      X11Forwarding = false;
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "24h";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowPing = true;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
