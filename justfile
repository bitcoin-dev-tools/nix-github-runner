set shell := ["bash", "-uc"]

os := os()
ax52 := 'ax52'
github-runner := 'runner-root'
GH_TOKEN := env('RUNNER_TOKEN', 'RUNNER_TOKEN NOT SET')

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

# Rebuild a github CI runner on a machine with a new token
[group('live')]
rebuild type=ax52 host=github-runner gh_token=GH_TOKEN:
    RUNNER_TOKEN={{gh_token}} nixos-rebuild switch --flake .#{{type}} --target-host {{host}} --impure
    echo "After sync, to apply config run:"
    echo "ssh {{host}} "cd /etc/nixos-config && source .env && RUNNER_TOKEN=\$GH_TOKEN nixos-rebuild switch --flake .#{{type}} --impure && rm -f .env"

