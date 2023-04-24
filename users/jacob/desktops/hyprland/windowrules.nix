# <https://wiki.hyprland.org/Configuring/Window-Rules/#window-rules-v2>
{lib, ...}: let
  # I recommend using this factory function for creating window rules.
  rule = rules: {
    class ? null,
    title ? null,
  }: {inherit class title rules;};
in {
  wayland.windowManager.hyprland.windowRules = let
    ### SYSTEM CONTROL ###
    printerConfig.class = ["system-config-printer"];
    audioControl.class = ["pavucontrol-qt"];
    wifiControl.class = ["org\.twosheds\.iwgtk" "iwgtk"];
    bluetoothControl = {
      class = [".*blueman-manager.*"];
      title = ["Bluetooth Devices"];
    };
    kvantumConfig.class = ["kvantummanager"];

    ### SYSTEM MODALS ###
    filePickerPortal = {
      # I'm guessing that almost all portal interfaces are going to be modals
      class = [
        "xdg-desktop-portal-gtk"
        "org\.freedesktop\.impl\.portal\.desktop\.kde"
      ];
      # title = ["Open Files.+Portal"];
    };
    polkitAgent.class = ["lxqt-policykit-agent"];
    mountDialog.class = ["udiskie"];

    ### DESKTOP APPLICATIONS ###
    vscode = {
      title = [".*Visual Studio Code"];
      # class = ["code-url-handler"];
    };
    discord = {
      class = ["WebCord" "discord"];
      title = ["(\\[\\d+\\] )?WebCord.*" ".*Discord"];
    };
    calculator.class = ["qalculate-gtk"];
    obsStudio = {
      class = ["com\.obsproject\.Studio"];
      title = ["OBS\\s[\\d\\.]+.*"];
    };
    steam = {
      class = ["Steam"];
      # title = ["Steam"];
    };
    minecraft = {
      class = ["Minecraft.+"];
      title = ["Minecraft.+"];
    };
    virtManagerConsole = {
      class = ["virt-manager"];
      title = [".+on.+"];
    };

    ### DESKTOP APPLICATION MODALS ###
    discordModal = {
      class = ["WebCord"];
      title = ["WebCord.+Settings"];
    };
    keePassModal = {
      class = ["org\.keepassxc\.KeePassXC"];
      title = [
        "Unlock Database.+KeePassXC"
        "Generate Password"
        "KeePassXC.+Browser Access Request"
      ];
    };
    firefoxModal = {
      class = ["firefox"];
      title = ["Extension.+Mozilla Firefox.*"];
    };
    lxImageModal = {
      class = ["lximage-qt"];
      title = ["Print"];
    };
    fileZillaModal = {
      class = ["filezilla"];
      title = ["Site Manager"];
    };
  in
    lib.concatLists [
      [
        (rule ["size 740 460"] filePickerPortal)
        (rule ["size 950 700"] kvantumConfig)
        (rule ["size 1200 800"] obsStudio)
      ]
      (map (rule ["idleinhibit focus"]) [
        minecraft
        virtManagerConsole
      ])
      (map (rule ["float"]) [
        kvantumConfig
        keePassModal
        lxImageModal
        firefoxModal
        fileZillaModal
        discordModal
        obsStudio
      ])
      (map (rule ["opacity 0.97 0.97"]) [
        vscode
        discord
      ])
      (map (rule ["opacity 0.97 0.97" "float"]) [
        printerConfig
        audioControl
        wifiControl
        bluetoothControl
        polkitAgent
        mountDialog
      ])
      (map (rule ["opacity 0.92 0.92"]) [
        steam
      ])
      (map (rule ["opacity 0.92 0.92" "float"]) [
        filePickerPortal
      ])
      (map (rule ["opacity 0.87 0.87"]) [])
      (map (rule ["opacity 0.87 0.87" "float"]) [
        calculator
      ])
    ];
}
