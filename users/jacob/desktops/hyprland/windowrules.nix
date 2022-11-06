# <https://wiki.hyprland.org/Configuring/Window-Rules/#window-rules-v2>
{lib, ...}: let
  # I recommend using this factory function for creating window rules.
  rule = rules: {
    class ? null,
    title ? null,
  }: {inherit class title rules;};

  # a bunch of pairs of regex strings for the class and titles to look for
  patterns = {
    ### SYSTEM CONTROL ###
    printerConfig.class = ["system-config-printer"];
    audioControl.class = ["pavucontrol-qt"];
    bluetoothControl = {
      class = [".*blueman-manager"];
      title = ["Bluetooth Devices"];
    };
    kvantumConfig.class = ["kvantummanager"];

    ### SYSTEM MODALS ###
    filePickerPortal.class = ["xdg-desktop-portal-gtk"];
    polkitAgent.class = ["lxqt-policykit-agent"];
    mountDialog.class = ["udiskie"];

    ### DESKTOP APPLICATIONS ###
    firefoxExtension.title = ["Extension.+Firefox.*"];
    vscode = {
      title = [".*Visual Studio Code"];
      # class = ["code-url-handler"];
    };
    discord = {
      class = ["Electron"];
      title = ["(\\[\\d+\\] )?WebCord.*"];
    };
    discordPopup = {
      class = ["Electron"];
      title = ["WebCord.+Settings"];
    };
    calculator.class = ["qalculate-gtk"];
    obsStudio = {
      class = ["com.obsproject.Studio"];
      title = ["OBS\\s[\\d\\.]+.*"];
    };
    steam = {
      class = ["Steam"];
      title = ["Steam"];
    };
    minecraft = {
      class = ["Minecraft.+"];
      title = ["Minecraft.+"];
    };
  };
in {
  wayland.windowManager.hyprland.config.windowRules.rules = with patterns;
    lib.concatLists [
      [
        (rule ["size 740 460"] filePickerPortal)
        (rule ["size 950 700"] kvantumConfig)
        (rule ["size 1200 800"] obsStudio)
      ]
      (map (rule ["idleinhibit focus"]) [
        minecraft
      ])
      (map (rule ["float"]) [
        kvantumConfig
        firefoxExtension
        discordPopup
        obsStudio
      ])
      (map (rule ["opacity 0.97 0.97"]) [
        discord
      ])
      (map (rule ["opacity 0.97 0.97" "float"]) [
        printerConfig
        audioControl
        bluetoothControl
        polkitAgent
        mountDialog
      ])
      (map (rule ["opacity 0.92 0.92"]) [
        vscode
      ])
      (map (rule ["opacity 0.92 0.92" "float"]) [
        filePickerPortal
        steam
      ])
      (map (rule ["opacity 0.87 0.87"]) [])
      (map (rule ["opacity 0.87 0.87" "float"]) [
        calculator
      ])
    ];
}
