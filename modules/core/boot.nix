{ ... }:
{
  boot = {
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    kernelModules = [
      "msr"
      "cpuid"
      "x86_pkg_temp_thermal"
    ];
    kernel.sysctl = {
      "dev.perf_event_mlock_kb" = 516096;
      "kernel.kptr_restrict" = 0;
      "kernel.nmi_watchdog" = 0;
      "kernel.numa_balancing" = 0;
      "kernel.perf_cpu_time_max_percent" = 75;
      "kernel.perf_event_max_sample_rate" = 200;
      "kernel.perf_event_paranoid" = -1;
      "kernel.randomize_va_space" = 2;
      "kernel.sched_autogroup_enabled" = 0;
      "kernel.sched_migration_cost_ns" = 5000000;
      "kernel.sched_min_granularity_ns" = 10000000;
      "kernel.sched_nr_migrate" = 0;
      "kernel.sched_rt_runtime_us" = -1;
    };
  };

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
