{pkgs, ...}: {
  programs.vscode.extensions = with pkgs.vscode-marketplace; [
    marp-team.marp-vscode
  ];
}
