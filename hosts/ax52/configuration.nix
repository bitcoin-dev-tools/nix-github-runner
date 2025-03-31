{ config, pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ../../modules/core
    ../../modules/services
    ../../modules/users
    ../../modules/tools
  ];

  boot = {
    # Add pyperf system advice for 8 Core (16 thread) AMD Ryzen™ 7 7700 found in AX52:
    # https://www.hetzner.com/dedicated-rootserver/ax52/
    # =======
    # ASLR: Enable full randomization: write 2 into /proc/sys/kernel/randomize_va_space
    # Linux scheduler: Use isolcpus=<cpu list> kernel parameter to isolate CPUs
    # Linux scheduler: Use rcu_nocbs=<cpu list> kernel parameter (with isolcpus) to not schedule RCU on isolated CPUs
    kernelParams = [
      "processor.max_cstate=1"
      "idle=poll"
      "tsc=reliable"
      "isolcpus=2-15" # Isolate CPUs 2-15 from the general scheduler
      "nohz_full=2-15" # Enable full dynticks system for isolated CPUs
      "rcu_nocbs=2-15" # Don't run RCU callbacks on isolated CPUs
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
