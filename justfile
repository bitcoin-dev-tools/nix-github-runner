set shell := ["bash", "-uc"]

os := os()
ax52 := 'ax52'
github-runner := 'github-runner'
GH_TOKEN := env('GH_TOKEN', 'GH_TOKEN NOT SET')

[private]
default:
    just --list

# Build configuration without deploying
[group('test')]
build type=ax52:
    nix-shell -p nixos-rebuild --command "nixos-rebuild build --flake .#{{type}} --show-trace"

# Build VM for testing
[group('test')]
build-vm type=ax52:
    nix-shell -p nixos-rebuild --command "nixos-rebuild build-vm --flake .#{{type}} --show-trace"

# Show what would change without building
[group('test')]
dry-run type=ax52:
    nix-shell -p nixos-rebuild --command "nixos-rebuild dry-run --flake .#{{type}} --show-trace"

# Deploy a github CI runner to a machine
[group('live')]
deploy type=ax52 host=github-runner:
    nix-shell -p nixos-anywhere --command "nixos-anywhere --flake .#{{type}} {{host}}"

# Rebuild a github CI runner on a machine with a new token
[group('live')]
rebuild type=ax52 host=github-runner gh_token=GH_TOKEN:
    nix-shell -p nixos-rebuild --command "RUNNER_TOKEN={{gh_token}} nixos-rebuild switch --flake .#{{type}} --target-host {{host}} --impure"
