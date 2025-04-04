profileName:
{ pkgs, ... }: {
  programs.vscode.profiles.${profileName} = {
    extensions = with pkgs.vscode-marketplace; [ wackbyte.hare ];
  };
}
