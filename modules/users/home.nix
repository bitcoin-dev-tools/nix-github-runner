{ pkgs, ... }:
{
  home-manager.users = {
    satoshi = with pkgs; {
      home.packages = [
        direnv
        fzf
        starship
        zoxide
      ];
      home.preferXdgDirectories = true;

      home.shellAliases = {
        vim = "nvim";
        ls = "eza";
        ll = "eza -al";
        ".." = "cd ..";
      };

      home.file."src/core/.keep".text = "";
      home.file."src/core/.envrc".text = ''
        use nix
        export VIRTUAL_ENV=$PWD/.venv
        layout python3
      '';

      programs = {
        bash.enable = true;
        bash.bashrcExtra = '''';

        direnv = {
          enable = true;
          enableBashIntegration = true;
          package = pkgs.direnv;
          nix-direnv = {
            enable = true;
            package = pkgs.nix-direnv;
          };
        };

        fzf = {
          enable = true;
          enableBashIntegration = true;
        };

        starship = {
          enable = true;
          settings = {
            directory.truncation_length = 2;
            gcloud.disabled = true;
            memory_usage.disabled = true;
            shlvl.disabled = false;
          };
        };

        zoxide = {
          enable = true;
          enableBashIntegration = true;
        };

        home-manager.enable = true;
      };

      home.stateVersion = "24.11";
    };

    github-runner = {
      programs.bash = {
        enable = true;
        bashrcExtra = ''
          GUIX_PROFILE=/home/github-runner/.config/guix/current
          . "$GUIX_PROFILE/etc/profile"
        '';
        profileExtra = ''
          GUIX_PROFILE=/home/github-runner/.config/guix/current
          . "$GUIX_PROFILE/etc/profile"
        '';
      };
      home.stateVersion = "24.11";
    };
  };
}
