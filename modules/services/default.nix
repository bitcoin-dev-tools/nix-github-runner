{ ... }: {
  imports = [
    # ./guix-test.nix
    ./github-runner.nix
    ./ssh.nix
  ];
  disabledModules = [
    "services/continuous-integration/github-runner/options.nix"
    "services/continuous-integration/github-runner/service.nix"
  ];
}
