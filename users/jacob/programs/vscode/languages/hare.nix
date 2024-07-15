{ pkgs, ... }: {
  programs.vscode.extensions = with pkgs.vscode-marketplace; [ wackbyte.hare ];
}
