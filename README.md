# NixOS benchmarking setup

## Deploy

To deploy to a server, either select and existing *disk-config\*.nix*, or create a new one tailored to the target host.
This example will use a Hetzner AX52 as target, which comes with 2 SSDs located at */dev/nvme1n1* and */dev/nvme0n1*.

### Load NixOS configuration

```bash
$ nix-shell -p nixos-anywhere
[nix-shell:~]$ RUNNER_TOKEN=<github runner token> nixos-anywhere --flake .#ax52 root@<ip_address>
```

Or using `just`:

```bash
just deploy ax52 <host> <token>
```

## Update

- Stage or commit changes

```bash
$ nix-shell -p nixos-rebuild
[nix-shell:~]$ RUNNER_TOKEN=<github runner token> nixos-rebuild switch --flake .#ax52 --target-host root@<ip_address>
```

Or using `just`:

```bash
just rebuild ax52 <host> <token>
```
