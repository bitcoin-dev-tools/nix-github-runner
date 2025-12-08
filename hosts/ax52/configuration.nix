{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ../../modules/core
    ../../modules/services
    ../../modules/users
    ../../modules/tools
  ];

  boot = {
    # Performance tuning for AMD Ryzen 7 7700 (AX52)
    # Benchmarks use taskset at runtime for CPU isolation
    kernelParams = [
      "processor.max_cstate=1"
      "idle=poll"
      "tsc=reliable"
      "amd_pstate=active" # Enable AMD P-State driver
    ];
    kernelPackages = pkgs.linuxPackages_6_6;
  };

  system.activationScripts = {
    setDataPermissions = ''
      chown satoshi:users /data
    '';

    # Create kernel modules directory structure
    kernelModules = ''
      mkdir -p /lib/modules/${config.boot.kernelPackages.kernel.version}
      ln -sfn ${config.boot.kernelPackages.kernel.dev}/lib/modules/${config.boot.kernelPackages.kernel.version}/* /lib/modules/${config.boot.kernelPackages.kernel.version}/
    '';

    # Limit CPU frequency to 4.2GHz
    fixCpuFreq = ''
      for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        if [ -d "$cpu/cpufreq" ]; then
          echo "Setting frequency limits for $(basename "$cpu")"
          echo 4200000 > "$cpu/cpufreq/scaling_max_freq"
          echo 4200000 > "$cpu/cpufreq/scaling_min_freq"
        fi
      done
    '';
  };
}
