# NixOS GitHub Runner

A NixOS configuration for deploying a GitHub self-hosted runner.

## Introduction

This repository currently deploys a runner directly on the target NixOS host.
It does not currently configure Firecracker or `microvm.nix` runners.

To use it, first provision a server and ensure that you have root `ssh` access
to the host. Then use
[`nixos-anywhere`](https://github.com/nix-community/nixos-anywhere) to install
NixOS from the flake. This installs the packages and services described in
`flake.nix` and the imported host configuration.

The GitHub runner token is managed with `sops-nix` from
`secrets/default.yaml`, not by passing `GH_TOKEN` during rebuilds.

The configured runner is ephemeral and registers against the
`bitcoin-dev-tools` GitHub organization.

## Initial deployment

To initially deploy to a server, either select an existing `disk-config.nix`, or
create a new one tailored to the target host. This example uses a Hetzner AX52,
which comes with two SSDs located at `/dev/nvme1n1` and `/dev/nvme0n1`.

### Add your SSH key

To connect to the remote host after installation, provision it with your SSH
key. Modify the `ssh_keys` list in `modules/users/default.nix` before
deploying.

### Configure the runner token

The runner token is read from `sops.secrets.runner_token`, configured in
`modules/services/github-runner.nix` and encrypted in `secrets/default.yaml`.

The token file should contain either a GitHub personal access token with
self-hosted runner permissions, or a runner registration token. A PAT is
preferred because registration tokens expire after one hour.

### Install NixOS

```bash
$ nix-shell -p nixos-anywhere
[nix-shell:~]$ nixos-anywhere --flake .#ax52 root@<ip_address>
```

Or using `just`:

```bash
just deploy ax52 <host>
```

## Rebuild or update deployment

- Stage or commit changes

### (Optional) Perform a dry-run

You can perform a dry-run with:

```bash
just dry-run ax52
```

### Live update

```bash
$ nix-shell -p nixos-rebuild
[nix-shell:~]$ nixos-rebuild switch --flake .#ax52 --target-host root@<ip_address>
```

Or using `just`:

```bash
just rebuild ax52 <host>
```

## Adding a new runner type

Adding a new generic runner can be made more straightforward in the future (see below), but for now remains semi-manual.

### Disk setup

Most of this configuration is generic-enough to be used on a wide range of hardware, however as it currently stands disks should be manually configured.
This is typically done by `ssh`-ing into the server and running e.g. `lsblk` to see mounted block devices.

The disk configuration can then be transcribed into new file following the format similar to that found in [hosts/ax52/disk-config.nix](hosts/ax52/disk-config.nix) as appropriate.

In the future, if we want to support generic runners more easily, see [Section 8](https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md#8-prepare-hardware-configuration) of the `nixos-anywhere` documentation for usage of `--generate-hardware-config nixos-generate-config ./hardware-configuration.nix` or `nixos-facter`.
These can both be used to automatically fetch disk information and generate a generic hardware configuration for the host.

### Add new runner

Next, in `flake.nix` add a new entry under `nixosConfigurations` for the new runner (giving it a new name).
This should also import your new `disk-config-*.nix` file you created previously, and any other hardware-specific config files.

### Deploy

Deploy the new runner as described in the [Initial Deployment](#initial-deployment) section above.
