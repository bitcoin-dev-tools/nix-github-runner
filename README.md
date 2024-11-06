# NixOS GitHub runner

A configuration to deploy a NixOS GitHub self-hosted runner.

## Deploy

To deploy to a server, either select and existing *disk-config\*.nix*, or create a new one tailored to the target host.
This example will use a Hetzner AX52 as target, which comes with 2 SSDs located at */dev/nvme1n1* and */dev/nvme0n1*.

### Load NixOS configuration

```bash
$ nix-shell -p nixos-anywhere
[nix-shell:~]$ nixos-anywhere --flake .#ax52 root@<ip_address>
```

Or using `just`:

```bash
just deploy ax52 <host>
```

> [!NOTE]
> This does not deploy a github runner token.
> Re-run update after first deployment with a token to deploy it.

> [!WARNING]
> This token is stored in the nix store on the remote host.
> This is simpler than using SOPS or other mechanisms, but allows any user on the remote host to view it.

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
