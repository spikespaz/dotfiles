args @ {mkModuleIndex, ...}:
mkModuleIndex {
  path = ./.;
  include = {
    mcpelauncher = {pkgs, ...}: {
      home.packages = [pkgs.mcpelauncher-qt5];
    };
  };
}
args
