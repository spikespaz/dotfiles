{ lib, ... }:
let mkOverride = lib.mkOverride 80;
in { programs.vscode.userSettings = { "editor.fontSize" = mkOverride 14; }; }
