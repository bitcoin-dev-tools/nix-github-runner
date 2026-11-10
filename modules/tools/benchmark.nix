{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ccache
    perf
    flamegraph
    glibc.debug
    hyperfine
    perf-tools
  ];
}
