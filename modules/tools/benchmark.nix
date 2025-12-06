{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ccache
    config.boot.kernelPackages.perf
    flamegraph
    glibc.debug
    hyperfine
    perf-tools
  ];
}
