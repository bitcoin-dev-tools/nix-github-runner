{ config, pkgs, ... }: {
  boot = {
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    kernelModules = [ "msr" "cpuid" "x86_pkg_temp_thermal" ];
    # Add pyperf system advice:
    # =======
    # Perf event: Set max sample rate to 1
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
    ];
    kernelPackages = pkgs.linuxPackages_6_6;

    kernel.sysctl = {
      "dev.perf_event_mlock_kb" = 516096;
      "kernel.kptr_restrict" = 0;
      "kernel.nmi_watchdog" = 0;
      "kernel.numa_balancing" = 0;
      "kernel.perf_cpu_time_max_percent" = 75;
      "kernel.perf_event_max_sample_rate" = 100000;
      "kernel.perf_event_paranoid" = -1;
      "kernel.randomize_va_space" = 2; # Enable full randomization
      "kernel.sched_autogroup_enabled" = 0;
      "kernel.sched_migration_cost_ns" = 5000000;
      "kernel.sched_min_granularity_ns" = 10000000;
      "kernel.sched_nr_migrate" = 0;
      "kernel.sched_rt_runtime_us" = -1;
    };
  };

  # Create kernel modules directory structure
  system.activationScripts.kernelModules = ''
    mkdir -p /lib/modules/${config.boot.kernelPackages.kernel.version}
    ln -sfn ${config.boot.kernelPackages.kernel.dev}/lib/modules/${config.boot.kernelPackages.kernel.version}/* /lib/modules/${config.boot.kernelPackages.kernel.version}/
  '';

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
    powertop.enable = false;
  };

  services = {
    timesyncd.enable = false;
    acpid.enable = false;
    thermald.enable = false;
    power-profiles-daemon.enable = false;
  };
}
