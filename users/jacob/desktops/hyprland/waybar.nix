{
  lib,
  pkgs,
  ...
}: let
  # package overridden for hyprland-specific patches
  # <https://wiki.hyprland.org/Useful-Utilities/Status-Bars/#clicking-on-a-workspace-icon-does-not-work>
  # TODO upstream this to the Hyprland flake!
  package = pkgs.waybar.overrideAttrs (old: {
    mesonFlags = old.mesonFlags ++ ["-Dexperimental=true"];
    # needs hyprctl for workspace switching
    # included in the systemd unit's Environment PATH
    buildInputs = old.buildInputs ++ [pkgs.hyprland];
    postPatch = ''
      sed -i 's/zext_workspace_handle_v1_activate(workspace_handle_);/const std::string command = "hyprctl dispatch workspace " + name_;\n\tsystem(command.c_str());/g' src/modules/wlr/workspace_manager.cpp
    '';
  });

  fontPackages = [
    pkgs.ubuntu_font_family
    pkgs.material-design-icons
  ];

  compileSCSS = name: source: "${pkgs.runCommandLocal name {} ''
    mkdir -p $out
    ${lib.getExe pkgs.sassc} -t expanded '${source}' > $out/${name}.css
  ''}/${name}.css";

  # TODO when using store paths to executables, they do not inherit the user's
  # environment (at least with systemd) and therefore GUIs use the default theme
  commands = let
    busctl = "${pkgs.systemd}/bin/busctl";
    hyprctl = "${pkgs.hyprland}/bin/hyprctl";
    # TODO this is duplicated from the hyprland config, make it a module
    kbFns = lib.getExe (pkgs.keyboard-functions.override {
      scriptOptions = {
        # to get it to the top of the list
        urgency = "critical";
        outputMaximum = 1.25;
        colors.normalHighlight = "#458588e6";
        colors.warningHighlight = "#cc241de6";
      };
    });
    pavucontrol = lib.getExe pkgs.lxqt.pavucontrol-qt;
    blueman-manager = "${pkgs.blueman}/bin/blueman-manager";
    bluetoothctl = "${pkgs.bluez}/bin/bluetoothctl";
    iwgtk = lib.getExe pkgs.iwgtk;
  in {
    backlightUp = "${busctl} --user call org.clight.clight /org/clight/clight org.clight.clight IncBl d 0.05";
    backlightDown = "${busctl} --user call org.clight.clight /org/clight/clight org.clight.clight DecBl d 0.05";
    # TODO --tab no longer works, what is the identifier to use?
    outputSoundSettings = "${pavucontrol} --tab 'Output Devices'";
    outputVolumeMute = "${kbFns} output mute";
    outputVolumeUp = "${kbFns} output +0.05";
    outputVolumeDown = "${kbFns} output -0.05";
    # TODO --tab no longer works, what is the identifier to use?
    inputSoundSettings = "${pavucontrol} --tab 'Input Devices'";
    inputVolumeMute = "${kbFns} input mute";
    # inputVolumeUp = "${kbFns} input +0.05";
    # inputVolumeDown = "${kbFns} input -0.05";
    bluetoothSettings = blueman-manager;
    bluetoothOn = "rfkill unblock bluetooth && sleep 5; ${bluetoothctl} power on";
    bluetoothOff = "${bluetoothctl} power off";
    wirelessSettings = iwgtk;
    workspaceSwitchPrev = "${hyprctl} dispatch workspace m-1";
    workspaceSwitchNext = "${hyprctl} dispatch workspace m+1";
  };
in {
  programs.waybar.enable = true;

  programs.waybar.package = pkgs.symlinkJoin {
    name = package.name;
    paths = [package] ++ fontPackages;
  };

  programs.waybar.systemd.enable = true;

  systemd.user.services.waybar.Service.Environment = [
    # fix mainly for missing the hyprctl binary
    "PATH=${lib.makeBinPath package.buildInputs}"
  ];

  programs.waybar.style =
    builtins.readFile (compileSCSS "waybar-style" ./waybar.scss);

  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "top";
      mode = "dock";
      height = 26;

      modules-left = [
        "wlr/workspaces"
        "hyprland/window"
      ];

      modules-center = [
        "clock#time"
        "clock#date"
      ];

      modules-right = [
        "pulseaudio#output"
        "backlight"
        "memory"
        "cpu"
        "battery"
        "network"
        "bluetooth"
        "idle_inhibitor"
      ];

      ## MODULES-LEFT ##

      "wlr/workspaces" = {
        sort-by-number = true;

        on-click = "activate";
        on-scroll-up = commands.workspaceSwitchPrev;
        on-scroll-down = commands.workspaceSwitchNext;
      };
      "hyprland/window" = {
        max-length = 70;
      };

      ## MODULES-CENTER ##

      "clock#time" = {
        format = "{:%I:%M %p}";
      };

      "clock#date" = {
        format = "{:%A, %B %d}";
      };

      ## MODULES-RIGHT ##

      "pulseaudio#output" = {
        format = "{icon} {volume}%";
        format-muted = "󰖁 {volume}%";
        format-icons = {
          headphone = "󰋋";
          # speaker = "󰓃";
          hdmi = "󰽟";
          headset = "󰋎";
          # hands-free = "󰋎";
          # portable = "";
          # car = "󰄋";
          # hifi = "󰓃";
          # phone = "󰏲";
          default = ["󰕿" "󰖀" "󰕾"];
        };

        states = {
          warning = 101;
        };

        on-click = commands.outputSoundSettings;
        on-click-right = commands.outputVolumeMute;
        on-scroll-up = commands.outputVolumeUp;
        on-scroll-down = commands.outputVolumeDown;
      };

      # TODO volume
      "pulseaudio#input" = {
        format = "{format_source}";
        # format-source = "󰍬 {volume}%";
        # format-source-muted = "󰍭 {volume}%";
        format-source = "󰍬";
        format-source-muted = "󰍭";

        on-click = commands.inputSoundSettings;
        on-click-right = commands.inputVolumeMute;
        # on-scroll-up = commands.inputVolumeUp;
        # on-scroll-down = commands.inputVolumeDown;
      };

      backlight = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        # format-icons = ["󰃜" "󰃛" "󰃝" "󰃟" "󰃠"];
        format-icons = ["󱩎" "󱩏" "󱩐" "󱩑" "󱩒" "󱩓" "󱩔" "󱩕" "󱩖" "󰛨"];

        on-scroll-up = commands.backlightUp;
        on-scroll-down = commands.backlightDown;
      };

      memory = {
        interval = 10;
        format = "󰍛 {percentage}% ({used:.2g}/{total:.2g} GiB)";
      };

      cpu = {
        interval = 5;
        format = "󰘚 {usage}%";
      };

      temperature = {
        interval = 5;
        hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
        input-filename = "temp1_input";
        critical-threshold = 90; # 15C lower than Tjmax <https://www.amd.com/en/product/9686>
        format = "{icon} {temperatureC}°C";
        format-critical = "󰈸 {temperatureC}°C";
        # 4x low, 2x mid, 3x high, for 0-90
        format-icons = ["󱃃" "󱃃" "󱃃" "󱃃" "󰔏" "󰔏" "󱃂" "󱃂" "󱃂"];
      };

      network = let
        tooltip = ''
          <b>Address:</b> {ipaddr}
          <b>Netmask:</b> {netmask}
          <b>Gateway:</b> {gwaddr}
          <b>Speeds:</b> {bandwidthUpBytes} UL, {bandwidthDownBytes} DL
        '';
      in {
        format-ethernet = "󰈀 {ifname}";
        format-wifi = "{icon} {essid}";
        format-linked = "󱫱";
        format-disconnected = "󰲛";
        format-icons = ["󰤟" "󰤢" "󰤥" "󰤨"];

        tooltip-format = ''
          <b>Interface</b>: {ifname}
          ${tooltip}
        '';
        tooltip-format-wifi = ''
          <b>SSID:</b> {essid}
          <b>Strength:</b> {signaldBm} dBmW ({signalStrength}%)
          <b>Frequency:</b> {frequency} GHz
          ${tooltip}
        '';
        tooltip-format-disconnected = "Network disconnected.";

        on-click = commands.wirelessSettings;
      };

      bluetooth = {
        controller = "C0:3C:59:02:25:C3";
        format-on = "󰂯";
        format-off = "󰂲";
        format-disabled = "󰂲";
        format-connected = "󰂱 {num_connections}";
        format-connected-battery = "󰂱 {device_alias} ({device_battery_percentage}%) ({num_connections})";

        on-click = commands.bluetoothOn;
        on-click-middle = commands.bluetoothSettings;
        on-click-right = commands.bluetoothOff;
      };

      battery = {
        interval = 5;
        bat = "BAT0";
        # full-at = 94;
        format = "{icon} {capacity}%";
        format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        states = {
          battery-10 = 10;
          battery-20 = 20;
          battery-30 = 30;
          battery-40 = 40;
          battery-50 = 50;
          battery-60 = 60;
          battery-70 = 70;
          battery-80 = 80;
          battery-90 = 90;
          battery-100 = 100;
        };
        # <https://github.com/Alexays/Waybar/issues/1938>
        # the wiki lies about this, does not match
        # /sys/class/power_supply/BAT0/status
        format-plugged = "󰚥 AC";
        format-charging-battery-10 = "󰢜 {capacity}%";
        format-charging-battery-20 = "󰂆 {capacity}%";
        format-charging-battery-30 = "󰂇 {capacity}%";
        format-charging-battery-40 = "󰂈 {capacity}%";
        format-charging-battery-50 = "󰢝 {capacity}%";
        format-charging-battery-60 = "󰂉 {capacity}%";
        format-charging-battery-70 = "󰢞 {capacity}%";
        format-charging-battery-80 = "󰂊 {capacity}%";
        format-charging-battery-90 = "󰂋 {capacity}%";
        format-charging-battery-100 = "󰂅 {capacity}%";
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "󰈈";
          deactivated = "󱎫";
        };
        tooltip-format-activated = "Idle timer inhibited, device will not sleep.";
        tooltop-format-deactivated = "Idle timer enabled, device will sleep when not in use.";
      };
    };
  };
}
