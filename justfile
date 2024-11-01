set shell := ["bash", "-uc"]

os := os()

default:
    just --list

# Deploy a github CI runner to a machine
[group('runner')]
deploy type host runner_token:
    nix-shell -p nixos-anywhere --command "RUNNER_TOKEN={{runner_token}} nixos-anywhere --flake ./nix/ci/github-runner#{{type}} {{host}} --impure"

# Deploy a github CI runner to a machine
[group('runner')]
rebuild type host runner_token:
    nix-shell -p nixos-rebuild --command "RUNNER_TOKEN={{runner_token}} nixos-rebuild switch --flake ./nix/ci/github-runner#ax52 --target-host {{host}} --impure"
