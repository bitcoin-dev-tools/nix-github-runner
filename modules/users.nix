{ config, lib, pkgs, ... }:
let
  ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH988C5DbEPHfoCphoW23MWq9M6fmA4UTXREiZU0J7n0 will.hetzner@temp.com";
in
{
  users = {
    users.root = {
      openssh.authorizedKeys.keys = [ ssh_key ];
    };

    users.satoshi = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ ssh_key ];
      extraGroups = [ "wheel" ];
      home = "/home/satoshi";
    };
  };

  home-manager.users.satoshi = with pkgs; {
    home.packages = [
      direnv
      fzf
      starship
      zoxide
    ];
    home.preferXdgDirectories = true;

    # Aliases which apply across all shells
    home.shellAliases = {
      vim = "nvim";
      ls = "eza";
      ll = "eza -al";
      ".." = "cd ..";
    };

    # Create src/core directory
    home.file."src/core/.keep".text = "";
    home.file."src/core/.envrc".text = ''
      use nix
      export VIRTUAL_ENV=$PWD/.venv
      layout python3
    '';

    programs.bash.enable = true;
    programs.bash.bashrcExtra = ''
    '';

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      package = pkgs.direnv;
      nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv;
      };
    };

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.starship = {
      enable = true;
      settings = {
        directory.truncation_length = 2;
        gcloud.disabled = true;
        memory_usage.disabled = true;
        shlvl.disabled = false;
      };
    };

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    # Have home-manager manage itself
    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
  };

}
