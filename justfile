set shell := ["bash", "-uc"]

os := os()

default:
    just --list

# Deploy a github CI runner to a machine
[group('runner')]
deploy type host:
    nix-shell -p nixos-anywhere --command "nixos-anywhere --flake .#{{type}} {{host}}"

# Deploy a github CI runner to a machine
[group('runner')]
rebuild type host runner_token:
    nix-shell -p nixos-rebuild --command "RUNNER_TOKEN={{runner_token}} nixos-rebuild switch --flake .#{{type}} --target-host {{host}} --impure"
