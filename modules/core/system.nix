{ ... }:
{
  time.timeZone = "UTC";

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1month
  '';

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
    };
  };

  system.stateVersion = "24.11";
}
