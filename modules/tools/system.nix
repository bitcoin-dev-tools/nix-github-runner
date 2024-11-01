{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bat
    curl
    eza
    fd
    htop
    just
    mosh
    neovim
    ripgrep
    tmux
    magic-wormhole
    time
    jq
  ];
}
