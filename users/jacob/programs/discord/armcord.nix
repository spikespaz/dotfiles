{ pkgs, ... }:
let package = pkgs.armcord;
in {
  home.packages = [ package ];

  xdg.configFile."ArmCord/storage/settings.json".text = builtins.toJSON {
    windowStyle = "native";
    channel = "ptb";
    armcordCSP = true;
    minimizeToTray = false;
    automaticPatches = false;
    keybinds = [ ];
    alternativePaste = false;
    multiInstance = false;
    mods = "vencord";
    spellcheck = true;
    performanceMode = "battery";
    skipSplash = false;
    inviteWebsocket = true;
    startMinimized = false;
    dynamicIcon = false;
    tray = true;
    customJsBundle = "https://armcord.app/placeholder.js";
    customCssBundle = "https://armcord.app/placeholder.css";
    disableAutogain = false;
    useLegacyCapturer = false;
    mobileMode = false;
    trayIcon = "default";
    doneSetup = true;
    clientName = "ArmCord";
    customIcon = "${package}/opt/ArmCord/resources/app.asar/assets/desktop.png";
  };
}
