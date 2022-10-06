{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    perlPackages.PLS
  ];

  programs.vscode.extensions = with pkgs.vscode-extensions;
    [
      # empty
    ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        # Perl
        name = "pls";
        publisher = "fractalboy";
        version = "0.0.15";
        sha256 = "sha256-qMXaCxlvGUz7BXl6reFOXtLXV2JMzccxQO4VlvvZOQk=";
      }
    ];

  programs.vscode.userSettings = {
    "pls.cmd" = lib.getExe pkgs.perlPackages.PLS;
  };
}
