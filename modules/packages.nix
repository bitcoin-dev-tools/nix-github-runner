{ config, pkgs, ... }: {
  environment.enableDebugInfo = true;
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
    magic-wormhole
    time
    # Benchmarking
    ccache
    config.boot.kernelPackages.perf
    flamegraph
    glibc.debug
    hyperfine
    jq
    perf-tools
  ];
}
