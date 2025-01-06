{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bat
    curl
    eza
    fd
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
