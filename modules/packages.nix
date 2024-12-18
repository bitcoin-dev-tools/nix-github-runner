{ config, lib, pkgs, ... }:
let
  hyper-wrapper = pkgs.rustPlatform.buildRustPackage rec {
    pname = "hyper-wrapper";
    version = "0.1.1";
    src = pkgs.fetchCrate {
      inherit pname version;
      sha256 = "sha256-EjDIvCmW0q7ddjAR8hY0v/HFkWZil88gQuJrLbSssck=";
    };
    cargoHash = "sha256-TCaDh5yay1u+nS2iWnp0kGF/dTvxVteIFKxU8Ae1DrI=";
    meta = with pkgs.lib; {
      description = "Hyperfine wrapper";
      homepage = "https://github.com/bitcoin-dev-tools/hyper-wrapper";
      license = licenses.mit;
    };
  };
in
{
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
    ccache
    jq
    magic-wormhole
    time
    # Benchmarking
    hyperfine
    hyper-wrapper
    perf-tools
    flamegraph
    linuxKernel.packages.linux_6_6.perf
  ];
}
