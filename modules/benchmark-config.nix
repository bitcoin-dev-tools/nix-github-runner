{ config, lib, pkgs, ... }:

let
  benchmarkScript = pkgs.writeScriptBin "benchmark-tune" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    # Ensure MSR module is loaded
    ${pkgs.kmod}/bin/modprobe msr || true

    # Verify sysctl settings
    expected_rate=100000
    actual_rate=$(${pkgs.procps}/bin/sysctl -n kernel.perf_event_max_sample_rate)

    if [ "$actual_rate" != "$expected_rate" ]; then
      echo "Setting perf_event_max_sample_rate to $expected_rate"
      ${pkgs.procps}/bin/sysctl -w kernel.perf_event_max_sample_rate=$expected_rate
    fi

    # Run pyperf tune
    ${pkgs.python310Packages.pyperf}/bin/pyperf system tune || true

    exit 0
  '';
in
{
  boot.kernelModules = [ "msr" "cpuid" "x86_pkg_temp_thermal" ];

  boot.kernelParams = [
    "processor.max_cstate=1"
    "idle=poll"
    "tsc=reliable"
    # "isolcpus=1-15"
    # "rcu_nocbs=1-15"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest.extend (self: super: {
    kernel = super.kernel.override {
      debug = true;
    };
  });

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
    powertop.enable = false;
  };

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = lib.mkForce 0;
    "kernel.nmi_watchdog" = 0;
    "kernel.numa_balancing" = 0;
    "kernel.perf_cpu_time_max_percent" = 75;
    "kernel.perf_event_max_sample_rate" = 100000;
    "kernel.perf_event_paranoid" = -1;
    "kernel.randomize_va_space" = 0;
    "kernel.sched_autogroup_enabled" = 0;
    "kernel.sched_migration_cost_ns" = 5000000;
    "kernel.sched_min_granularity_ns" = 10000000;
    "kernel.sched_nr_migrate" = 0;
    "kernel.sched_rt_runtime_us" = -1;
  };

  services.udev.extraRules = ''
    KERNEL=="msr[0-9]*", GROUP="root", MODE="0644"
  '';

  systemd = {
    services.systemd-journald.environment.RUNTIME_DIRECTORY_SIZE = "64M";

    services.benchmark-tune = {
      description = "Configure system for benchmarking";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-sysctl.service" ];
      requires = [ "systemd-sysctl.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${benchmarkScript}/bin/benchmark-tune";
        Restart = "no";
        CapabilityBoundingSet = [ "CAP_SYS_ADMIN" "CAP_SYS_NICE" ];
        AmbientCapabilities = [ "CAP_SYS_ADMIN" "CAP_SYS_NICE" ];
        PrivilegeEscalationAllowed = true;
        NoNewPrivileges = false;
      };
    };
  };

  services = {
    timesyncd.enable = false;
    acpid.enable = false;
    thermald.enable = false;
    power-profiles-daemon.enable = false;

    journald.extraConfig = ''
      Storage=volatile
      ForwardToSyslog=no
      ForwardToKMsg=no
    '';
  };
}
