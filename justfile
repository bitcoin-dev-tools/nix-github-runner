set shell := ["bash", "-uc"]

os := os()

[private]
default:
    just --list

# Build configuration without deploying
[group('test')]
build type:
    nix-shell -p nixos-rebuild --command "nixos-rebuild build --flake .#{{type}} --show-trace"

# Build VM for testing
[group('test')]
build-vm type:
    nix-shell -p nixos-rebuild --command "nixos-rebuild build-vm --flake .#{{type}} --show-trace"

# Show what would change without building
[group('test')]
dry-run type:
    nix-shell -p nixos-rebuild --command "nixos-rebuild dry-run --flake .#{{type}} --show-trace"

# Deploy a github CI runner to a machine
[group('live')]
deploy type host:
    nix-shell -p nixos-anywhere --command "nixos-anywhere --flake .#{{type}} {{host}}"

# Rebuild a github CI runner on a machine with a new token
[group('live')]
rebuild type host runner_token:
    nix-shell -p nixos-rebuild --command "RUNNER_TOKEN={{runner_token}} nixos-rebuild switch --flake .#{{type}} --target-host {{host}} --impure"
