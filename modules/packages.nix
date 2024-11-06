{ config, lib, pkgs, ... }:
let
  hyper-wrapper = pkgs.rustPlatform.buildRustPackage rec {
    pname = "hyper-wrapper";
    version = "0.1.0";
    src = pkgs.fetchCrate {
      inherit pname version;
      sha256 = "sha256-11HJdxUshs+qfAqw4uqmY7z+XIGkdeUD9O4zl4fvDdE=";
    };
    cargoHash = "sha256-ffChU1z8VC2y7l6Pb/eX2XXdFDChMwnroSfsHIVChds=";
    meta = with pkgs.lib; {
      description = "Hyperfine wrapper";
      homepage = "https://github.com/bitcoin-dev-tools/hyper-wrapper";
      license = licenses.mit;
    };
  };
in
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
    # Benchmarking
    hyperfine
    hyper-wrapper
    perf-tools
    flamegraph
    linuxKernel.packages.linux_6_6.perf
  ];
}
