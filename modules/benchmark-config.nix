{ config, lib, pkgs, ... }:

let
  benchmarkScript = pkgs.writeScriptBin "benchmark-tune" ''
    #!${pkgs.bash}/bin/bash

    # Ensure MSR module is loaded
    ${pkgs.kmod}/bin/modprobe msr || true

    # Force ASLR off
    echo 0 > /proc/sys/kernel/randomize_va_space

    # Set CPU governor to performance for all CPUs
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
      echo performance > $cpu/cpufreq/scaling_governor 2>/dev/null || true
    done

    # Set IRQ affinity to spread across all CPUs (this should be default, but just in case)
    true

    # Run pyperf tune, don't die if we fail though
    ${pkgs.python310Packages.pyperf}/bin/pyperf system tune || true

    # Double-check ASLR is still off
    echo 0 > /proc/sys/kernel/randomize_va_space

    exit 0
  '';
in
{
  boot.kernelModules = [ "msr" "cpuid" ];

  # Kernel parameters ~ optimized for AMD Ryzen 7 7700
  boot.kernelParams = [
    # Performance settings
    "processor.max_cstate=1"
    "amd_pstate=performance"
    "idle=poll"
    # Ensure NUMA balancing is disabled
    "numa_balancing=disable"
    # Reduce timer frequency
    "tsc=reliable"
  ];

  # More aggressive CPU settings
  powerManagement = {
    enable = true;
    # This is the same as pyperf, probably one is redundant...
    cpuFreqGovernor = "performance";
    powertop.enable = false;
  };

  boot.kernel.sysctl = {
    # Force ASLR off
    "kernel.randomize_va_space" = 0;
    # Disable watchdogs
    "kernel.nmi_watchdog" = 0;
    # Performance settings
    "kernel.numa_balancing" = 0;
    "kernel.sched_rt_runtime_us" = -1;
    "kernel.sched_autogroup_enabled" = 0;
    "kernel.sched_min_granularity_ns" = 10000000;
    "kernel.sched_migration_cost_ns" = 5000000;
    "kernel.sched_nr_migrate" = 0;
  };

  # Systemd configuration
  systemd = {
    services.systemd-journald.environment.RUNTIME_DIRECTORY_SIZE = "64M";

    # Updated benchmark tuning service
    services.benchmark-tune = {
      description = "Configure system for benchmarking";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${benchmarkScript}/bin/benchmark-tune";
        Restart = "no";
      };
    };
  };

  # Disable services that might interfere
  services = {
    timesyncd.enable = false;
    acpid.enable = false;
    thermald.enable = false;
    power-profiles-daemon.enable = false;

    journald.extraConfig = ''
      Storage=volatile
      SystemMaxUse=64M
      RuntimeMaxUse=64M
      ForwardToSyslog=no
      ForwardToKMsg=no
    '';
  };

  # Ensure these settings persist
  environment.etc."sysctl.d/99-benchmark.conf".text = ''
    kernel.randomize_va_space = 0
    kernel.numa_balancing = 0
    kernel.sched_rt_runtime_us = -1
    kernel.nmi_watchdog = 0
  '';
}
