profileName:
{ lib, pkgs, ... }: {
  programs.vscode.profiles.${profileName} = {
    extensions = let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [
      ziglang.vscode-zig
      disaac.zlint-vscode
    ];

    userSettings = {
      "zig.path" = lib.getExe pkgs.zig;
      "zig.zls.path" = lib.getExe pkgs.zls;
      "zig.zls.zigLibPath" = "${pkgs.zig}/lib/zig";
      "zig.zls.enableBuildOnSave" = true;
      "zig.zls.highlightGlobalVarDeclarations" = true;
      "zig.zls.inlayHintsHideRedundantParamNames" = true;
      "zig.zls.warnStyle" = true;
    };
  };
}
