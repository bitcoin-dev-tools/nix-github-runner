{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Development tools
    bash
    coreutils
    docker
    findutils
    git
    gnugrep
    gnused
    gnutar
    podman
    python3

    # Shell utilities
    bat
    curl
    eza
    fd
    just
    mosh
    neovim
    ripgrep
    tmux

    # System tools
    ccache
    magic-wormhole
    time
  ];
}
