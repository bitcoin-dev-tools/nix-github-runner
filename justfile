set shell := ["bash", "-uc"]

os := os()
ax52 := 'ax52'
github-runner := 'runner-root'

[private]
default:
    just --list

# Build configuration without deploying
[group('test')]
build type=ax52:
    nixos-rebuild build --flake .#{{type}} --show-trace

# Build VM for testing
[group('test')]
build-vm type=ax52:
    nixos-rebuild build-vm --flake .#{{type}} --show-trace

# Show what would change without building
[group('test')]
dry-run type=ax52:
    nixos-rebuild dry-run --flake .#{{type}} --show-trace

# Deploy a github CI runner to a machine
[group('live')]
deploy type=ax52 host=github-runner:
    nix-shell -p nixos-anywhere --command "nixos-anywhere --flake .#{{type}} {{host}}"

# Copy flake to remote for local building
[group('live')]
sync host=github-runner:
    rsync -av --exclude=result* . {{host}}:/etc/nixos-config/
    ssh {{host}} "chown -R root:root /etc/nixos-config"

# Rebuild a github CI runner on a machine
[group('live')]
rebuild type=ax52 host=github-runner:
    nixos-rebuild switch --flake .#{{type}} --target-host {{host}}

