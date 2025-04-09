{ lib, pkgs, ... }: {
  programs.fish = {
    enable = true;

    interactiveShellInit = lib.concatLines [
      # Overrides the `source` and `.` commands to work with `.sh` files.
      "source ${pkgs.babelfish.src}/babel.fish"
    ];
  };

  home.packages = with pkgs.fishPlugins; [
    pkgs.babelfish

    # Prevent failed commands with typos from making it into history.
    # <https://github.com/meaningful-ooo/sponge>
    sponge

    # Expand `....` to `../..`,
    # expand `!!` to the previous command,
    # and `!$` to the last argument.
    puffer

    # TODO: Take notes about each of these.
    # Automatically insert pairs of grouping characters.
    # <https://github.com/jorgebucaran/autopair.fish>
    # autopair
    # Automatically insert pairs of grouping characters.
    # <https://github.com/laughedelic/pisces>
    pisces

    # Custom completion engine providing fuzzy search capabilities.
    # <https://github.com/gazorby/fifc>
    fifc
  ];

  programs.nix-your-shell = {
    enable = true;
    enableFishIntegration = true;
  };

  # Fuzzy finder with preview, provides `sk` command.
  # <https://github.com/skim-rs/skim>
  programs.skim = {
    enable = true;
    enableFishIntegration = true;
  };
}
