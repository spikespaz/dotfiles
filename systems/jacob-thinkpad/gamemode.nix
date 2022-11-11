{
  lib,
  pkgs,
  ...
}: {
  # <https://wiki.archlinux.org/title/AMDGPU#Boot_parameter>
  boot.kernelParams = ["amdgpu.ppfeaturemask=0xfff7ffff"];

  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        # The reaper thread will check every 5 seconds for exited clients,
        # for config file changes, and for the CPU/iGPU power balance
        reaper_freq = 5;

        # The desired governor is used when entering GameMode instead of "performance"
        desiredgov = "performance";
        # The default governor is used when leaving GameMode instead of restoring the original value
        # defaultgov = "powersave";

        # The iGPU desired governor is used when the integrated GPU is under heavy load
        # igpu_desiredgov = "performance";
        # Threshold to use to decide when the integrated GPU is under heavy load.
        # This is a ratio of iGPU Watts / CPU Watts which is used to determine when the
        # integraged GPU is under heavy enough load to justify switching to
        # igpu_desiredgov.  Set this to -1 to disable all iGPU checking and always
        # use desiredgov for games.
        # igpu_power_threshold = -1;

        # GameMode can change the scheduler policy to SCHED_ISO on kernels which support it (currently
        # not supported by upstream kernels). Can be set to "auto", "on" or "off". "auto" will enable
        # with 4 or more CPU cores. "on" will always enable. Defaults to "off".
        softrealtime = "off";

        # GameMode can renice game processes. You can put any value between 0 and 20 here, the value
        # will be negated and applied as a nice value (0 means no change). Defaults to 0.
        renice = 10;

        # By default, GameMode adjusts the iopriority of clients to BE/0, you can put any value
        # between 0 and 7 here (with 0 being highest priority), or one of the special values
        # "off" (to disable) or "reset" (to restore Linux default behavior based on CPU priority),
        # currently, only the best-effort class is supported thus you cannot set it here
        ioprio = 0;

        # Sets whether gamemode will inhibit the screensaver when active
        # Defaults to 1
        # <https://nixos.wiki/wiki/Gamemode#Known_Errors>
        inhibit_screensaver = 0;
      };

      filter = {
        # If "whitelist" entry has a value(s)
        # gamemode will reject anything not in the whitelist
        # whitelist = "RiseOfTheTombRaider";

        # Gamemode will always reject anything in the blacklist
        # blacklist = "HalfLife3";
      };

      gpu = {
        # Here Be Dragons!
        # Warning: Use these settings at your own risk
        # Any damage to hardware incurred due to this feature is your responsibility and yours alone
        # It is also highly recommended you try these settings out first manually to find the sweet spots

        # Setting this to the keyphrase "accept-responsibility" will allow gamemode to apply GPU optimisations such as overclocks
        apply_gpu_optimisations = "accept-responsibility";

        # The DRM device number on the system (usually 0), ie. the number in /sys/class/drm/card0/
        gpu_device = 0;

        # Nvidia specific settings
        # Requires the coolbits extension activated in nvidia-xconfig
        # This corresponds to the desired GPUPowerMizerMode
        # "Adaptive"=0 "Prefer Maximum Performance"=1 and "Auto"=2
        # See NV_CTRL_GPU_POWER_MIZER_MODE and friends in https://github.com/NVIDIA/nvidia-settings/blob/master/src/libXNVCtrl/NVCtrl.h
        # nv_powermizer_mode = 1;

        # These will modify the core and mem clocks of the highest perf state in the Nvidia PowerMizer
        # They are measured as Mhz offsets from the baseline, 0 will reset values to default, -1 or unset will not modify values
        # nv_core_clock_mhz_offset = 0;
        # nv_mem_clock_mhz_offset = 0;

        # AMD specific settings
        # Requires a relatively up to date AMDGPU kernel module
        # See: https://dri.freedesktop.org/docs/drm/gpu/amdgpu.html#gpu-power-thermal-controls-and-monitoring
        # It is also highly recommended you use lm-sensors (or other available tools) to verify card temperatures
        # This corresponds to power_dpm_force_performance_level, "manual" is not supported for now
        amd_performance_level = "high";
      };

      supervisor = {
        # This section controls the new gamemode functions gamemode_request_start_for and gamemode_request_end_for
        # The whilelist and blacklist control which supervisor programs are allowed to make the above requests
        # supervisor_whitelist = "";
        # supervisor_blacklist = "";

        # In case you want to allow a supervisor to take full control of gamemode, this option can be set
        # This will only allow gamemode clients to be registered by using the above functions by a supervisor client
        require_supervisor = 0;
      };

      custom = let
        title = "Game Mode";
        textSize = "x-large";
        bodyText = text: "<b><span size=\"${textSize}\">${text}</span></b>";
        activatedText = bodyText "Activated";
        deactivatedText = bodyText "Deactivated";
        urgencyActivated = "critical";
        urgencyDeactivated = "normal";
        timeoutActivated = 3000;
        timeoutDeactivated = 1500;
        category = "devices";
        icon = "input-gaming";
      in {
        # Custom scripts (executed using the shell) when gamemode starts and ends
        start = "${
          pkgs.writeShellScript "gamemode-activate-notification" ''
            ${pkgs.libnotify}/bin/notify-send \
              '${title}' \
              '${activatedText}' \
              -u ${urgencyActivated} \
              -t ${toString timeoutActivated} \
              -c ${category} \
              -i ${icon} \
              -h 'string:synchronous:toggle-gamemode'
          ''
        }";

        end = "${
          pkgs.writeShellScript "gamemode-deactivate-notification" ''
            ${pkgs.libnotify}/bin/notify-send \
              '${title}' \
              '${deactivatedText}' \
              -u ${urgencyDeactivated} \
              -t ${toString timeoutDeactivated} \
              -c ${category} \
              -i ${icon} \
              -h 'string:synchronous:toggle-gamemode'
          ''
        }";

        # Timeout for scripts (seconds). Scripts will be killed if they do not complete within this time.
        script_timeout = 10;
      };
    };
  };
}
