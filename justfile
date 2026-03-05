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

# Copy flake to remote and build remotely
[group('live')]
sync type=ax52 host=github-runner:
    rsync -av --delete --exclude=result* --exclude=.git . {{host}}:/etc/nixos-config/
    ssh {{host}} "chown -R root:root /etc/nixos-config && cd /etc/nixos-config && nixos-rebuild switch --flake .#{{type}}"

# Rebuild a github CI runner on a machine
[group('live')]
rebuild type=ax52 host=github-runner:
    nixos-rebuild switch --flake .#{{type}} --target-host {{host}}

# SSH into the host
[group('live')]
ssh host=github-runner:
    ssh {{host}}

# Get logs from bitcoind seed
[group('live')]
logs-seed host=github-runner:
    ssh {{host}} "tail -F /var/lib/bitcoind-source/debug.log"

# Get logs from github-runner
[group('live')]
logs-runner type=ax52 host=github-runner:
    ssh {{host}} "journalctl -f -u github-runner-{{type}}.service"

logs host=github-runner:
    ssh {{host}} "tail -F /data/runner_workspace/_temp/datadir/debug.log"
