{ ... }:
let
  ssh_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH988C5DbEPHfoCphoW23MWq9M6fmA4UTXREiZU0J7n0 will.hetzner@temp.com"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvfD+tZCrY9l+wSbCP3U82bWilXHBuGoMfUt7a33UoSt1nGbPZ3feXzjvSIEABs/T2shFyaIH/hEqB8FLT7A/jdmVEBOdQzB57IQPHjHrjASOdAUC4hx3VrxvQoIRWhwMbFRHQazZTAGqPi63tlQJHcmYrsY8YzQ/rn70owC/+jpvDVhUOFGAAgS0wR8Gygrl7atGevC1M2KhVI78ronHdSlV8q4qN8bVzdJgyJrAKBITosY8xDFB8xkv/XcFQcNuy04EuHP9ZILx/QBrbSvb0is0TmuyNGoa14zsaLcXhIxzQpRNNixZU8g6fY5Dm2r5E+qml31Wh/DO+N/ww1WcuKM8CiWAI3nW+qsD5rYaDjEmfiDq3TsO+emE2cKaUQeQEQPDJIm5YLF8ixqdKq0F6y/4MMOTXbwknegPMHfVagMPitmhDVOeuxlztnZ0uIMNuljVLiRwlVA33suOecNO8E/RbXxzPhccPMLolnlVmxEfJOCcwJyfsR7MHcFv7Vs0= josibake@josies-Laptop.local"
  ];
in
{
  imports = [ ./home.nix ];

  users = {
    users.root = {
      openssh.authorizedKeys.keys = ssh_keys;
    };

    users.satoshi = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = ssh_keys;
      extraGroups = [ "wheel" ];
      home = "/home/satoshi";
    };
  };
}
