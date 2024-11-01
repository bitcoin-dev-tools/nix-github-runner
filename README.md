# NixOS GitHub runner

A configuration to deploy a NixOS GitHub self-hosted runner.

## Introduction

We can easily add self-hosted GitHub Action Runners to our account by deploying them with NixOS.
To do this, first provision a VPS and ensure that you have root `ssh` capability on the host.

Next, We can use [`nixos-anywhere`](https://github.com/nix-community/nixos-anywhere) to fork the kernel process, and install NixOS on the machine.
This will also automatically install all packages and services described in the *flake.nix* and linked configurations.

Following this, all that remains is connecting your runner to your GitHub account/repository.
This can be done by obtaining a runner token, from GitHub web UI:

    Settings > Actions > Runners > New self-hosted runner

... and grabbing the token from the *configuration* section.

Finally, we can re-deploy the server, this time including the github runner token.

## Initial deployment

To initially deploy to a server, either select and existing *disk-config\*.nix*, or create a new one tailored to the target host.
This example will use a Hetzner AX52 as target, which comes with 2 SSDs located at */dev/nvme1n1* and */dev/nvme0n1*.

### Add your SSH key

In order to be able to connect in to the remote host, we need to provision it with your SSH key.
Modify the list of SSH keys at the top of *./modules/users.nix* to include your own before deploying.

### Install NixOS

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
[nix-shell:~]$ GH_TOKEN=<github runner token> nixos-rebuild switch --flake .#ax52 --target-host root@<ip_address>
```

Or using `just`:

```bash
export GH_TOKEN=<github token>

just rebuild ax52 <host>
```

> [!WARNING]
> This token **is** stored in the nix store on the remote host.
> This is simpler than using SOPS or other mechanisms, but allows any user on the remote host to view it.

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
