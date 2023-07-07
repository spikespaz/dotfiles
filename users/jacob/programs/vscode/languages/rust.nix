{ lib, pkgs, ... }: {
  programs.vscode.extensions = with pkgs.vscode-marketplace;
    with pkgs.vscode-marketplace-release; [
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      a5huynh.vscode-ron
      # these guys are sort of inconsiderate and not even designing
      # the extension properly, I should be able to provide
      # the binaries it wants and disable the auto download thing
      # <https://github.com/vadimcn/vscode-lldb/issues/310>
      pkgs.vscode-extensions.vadimcn.vscode-lldb
    ];

  programs.vscode.userSettings = {
    "[rust]" = {
      "editor.fontLigatures" = true;

      "editor.formatOnSave" = true;
    };

    # use clippy over cargo check
    "rust-analyzer.check.command" = "clippy";

    "rust-analyzer.server.path" = lib.getExe pkgs.rust-analyzer;

    # use nightly range formatting, should be faster
    "rust-analyzer.rustfmt.rangeFormatting.enable" = true;

    # use lldb for debugging
    "rust-analyzer.debug.engine" = "vadimcn.vscode-lldb";

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
    "rust-analyzer.inlayHints.lifetimeElisionHints.enable" =
      "always"; # or 'skip_trivial'
    # "rust-analyzer.inlayHints.lifetimeElisionHints.useParameterNames" = true;
  };
}
