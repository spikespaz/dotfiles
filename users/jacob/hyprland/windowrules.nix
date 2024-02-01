# <https://wiki.hyprland.org/Configuring/Window-Rules/#window-rules-v2>
{ lib, ... }:
let
  # I recommend using this factory function for creating window rules.
  rule = rules: attrs: attrs // { inherit rules; };
in {
  wayland.windowManager.hyprland.layerRules = [{
    namespace = [ "rofi" "notification" ];
    rules = [ "blur" "ignorezero" ];
  }];

  wayland.windowManager.hyprland.windowRules = let
    ### SYSTEM CONTROL ###
    printerConfig.class = [ "system-config-printer" ];
    audioControl.class = [ "pavucontrol-qt" ];
    wifiControl.class = [ "org.twosheds.iwgtk" "iwgtk" ];
    bluetoothControl = {
      class = [ ".*blueman-manager.*" ];
      title = [ "Bluetooth Devices" ];
    };
    kvantumConfig.class = [ "kvantummanager" ];

    ### SYSTEM MODALS ###
    filePickerPortal = {
      # I'm guessing that almost all portal interfaces are going to be modals
      class =
        [ "xdg-desktop-portal-gtk" "org.freedesktop.impl.portal.desktop.kde" ];
      # title = ["Open Files.+Portal"];
    };
    polkitAgent.class = [ "lxqt-policykit-agent" ];
    mountDialog.class = [ "udiskie" ];

    ### DESKTOP APPLICATIONS ###
    vscode = {
      title = [ ".*Visual Studio Code" ];
      # class = ["code-url-handler"];
    };
    discord = {
      class = [ "vesktop" "ArmCord" "WebCord" "discord" ];
      title = [
        "(\\[\\d+\\] )?Discord |.*"
        ".*ArmCord"
        "(\\[\\d+\\] )?WebCord.*"
        ".*Discord"
      ];
    };
    tidal.class = [ "tidal-hifi" ];
    calculator.class = [ "qalculate-gtk" ];
    # obsStudio = {
    #   class = [ "com.obsproject.Studio" ];
    #   title = [ "OBS\\s[\\d\\.]+.*" ];
    # };
    steam = {
      class = [ "Steam" ];
      # title = ["Steam"];
    };
    minecraft = {
      class = [ "Minecraft.+" ];
      title = [ "Minecraft.+" ];
    };
    virtManagerConsole = {
      class = [ "virt-manager" ];
      title = [ ".+on.+" ];
    };

    ### DESKTOP APPLICATION MODALS ###
    discordModal = {
      class = [ "WebCord" ];
      title = [ "WebCord.+Settings" ];
    };
    tidalModal = {
      class = [ "tidal-hifi" ];
      title = [ "Tidal Hi-Fi settings" ];
    };
    keePassModal = {
      class = [ "org.keepassxc.KeePassXC" ];
      title = [
        "Unlock Database.+KeePassXC"
        "Generate Password"
        "KeePassXC.+Browser Access Request"
      ];
    };
    firefoxModal = {
      class = [ "firefox" ];
      title = [ "Extension.+Mozilla Firefox.*" "Picture-in-Picture" ];
    };
    lxImageModal = {
      class = [ "lximage-qt" ];
      title = [ "Print" ];
    };
    fileZillaModal = {
      class = [ "filezilla" ];
      title = [ "Site Manager" ];
    };
  in lib.concatLists [
    [
      (rule [ "size 740 460" ] filePickerPortal)
      (rule [ "size 950 700" ] kvantumConfig)
    ]
    # Because it can be shown and hidden with a systray icon.
    (map (rule [ "float" "pin" "move 10% 10%" "size 80% 80%" ]) [ tidal ])
    #
    (map (rule [ "idleinhibit focus" ]) [ minecraft virtManagerConsole ])
    (map (rule [ "float" ]) [
      kvantumConfig
      keePassModal
      lxImageModal
      firefoxModal
      fileZillaModal
      discordModal
      tidalModal
    ])
    # Barely translucent
    (map (rule [ "opacity 0.97 0.97" ]) [ ])
    (map (rule [ "opacity 0.97 0.97" "float" ]) [
      printerConfig
      audioControl
      bluetoothControl
      polkitAgent
      mountDialog
    ])
    # More translucent
    (map (rule [ "opacity 0.92 0.92" ]) [ vscode steam tidal discord ])
    (map (rule [ "opacity 0.92 0.92" "float" ]) [
      filePickerPortal
      wifiControl
    ])
    # Super translucent
    (map (rule [ "opacity 0.87 0.87" ]) [ ])
    (map (rule [ "opacity 0.87 0.87" "float" ]) [ calculator ])
  ];
}
