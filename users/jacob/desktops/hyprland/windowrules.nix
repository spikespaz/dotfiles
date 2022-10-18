# <https://wiki.hyprland.org/Configuring/Window-Rules/#window-rules-v2>
{lib, ...}: let
  rule = rules: {
    class ? null,
    title ? null,
  }: {inherit class title rules;};

  opacity = lib.mapAttrs (_: x: toString (1 - x)) {
    low = 0.13;
    mid = 0.7;
    high = 0.04;
  };
  opacityRule =
    lib.mapAttrs' (name: x: {
      inherit name;
      value = "opacity ${x} ${x}";
    })
    opacity;

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
    vscode.title = [".+Visual Studio Code"];
    discord.class = ["discord" "webcord"];
    calculator.class = ["qalculate-gtk"];
    obsStudio = {
      class = ["com.obsproject.Studio"];
      title = ["OBS\s[\d\.]+.*"];
    };
    steam = {
      class = ["Steam"];
      title = ["Steam"];
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
      (map (rule ["float"]) [
        printerConfig
        audioControl
        bluetoothControl
        kvantumConfig
        filePickerPortal
        polkitAgent
        mountDialog
        firefoxExtension
        calculator
        obsStudio
        steam
      ])
      (map (rule [opacityRule.high]) [
        discord
      ])
      (map (rule [opacityRule.mid]) [
        printerConfig
        audioControl
        bluetoothControl
        filePickerPortal
        vscode
        steam
      ])
      (map (rule [opacityRule.low]) [
        calculator
      ])
    ];
}
