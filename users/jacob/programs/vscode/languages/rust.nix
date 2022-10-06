{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # empty
  ];

  programs.vscode.extensions = with pkgs.vscode-extensions; [
    rust-lang.rust-analyzer
  ];

  programs.vscode.userSettings = {
    "[rust]" = {
      "editor.fontLigatures" = true;

      "editor.formatOnSave" = true;
    };

    # use clippy over cargo check
    "rust-analyzer.checkOnSave.command" = "clippy";

    # use nightly range formatting, should be faster
    "rust-analyzer.rustfmt.rangeFormatting.enable" = true;

    # show references for everything
    "rust-analyzer.hover.actions.references.enable" = true;
    "rust-analyzer.lens.references.adt.enable" = true;
    "rust-analyzer.lens.references.enumVariant.enable" = true;
    "rust-analyzer.lens.references.method.enable" = true;
    "rust-analyzer.lens.references.trait.enable" = true;

    # enforce consistent imports everywhere
    "rust-analyzer.imports.granularity.enforce" = true;
    "rust-analyzer.imports.granularity.group" = "module";
    "rust-analyzer.imports.prefix" = "self";

    # show hints for elided lifetimes
    "rust-analyzer.inlayHints.lifetimeElisionHints.enable" = "always"; # or 'skip_trivial'
    # "rust-analyzer.inlayHints.lifetimeElisionHints.useParameterNames" = true;
  };
}
