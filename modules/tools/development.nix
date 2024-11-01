{ pkgs, ... }: {
  environment.enableDebugInfo = true;
  environment.systemPackages = with pkgs; [
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
  ];
}
