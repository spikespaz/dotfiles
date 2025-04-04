profileName:
{ ... }: {
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
  };
  programs.vscode.profiles.${profileName} = {
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
  };
}
