{ lib, pkgs, ... }: {
  home.packages = [ pkgs.rust-analyzer ];

  programs.vscode.extensions =
    let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [
      rust-lang.rust-analyzer
      serayuzgur.crates
      tamasfe.even-better-toml
      a5huynh.vscode-ron
      slint.slint
      slints.slintsvscodesnippets

      # these guys are sort of inconsiderate and not even designing
      # the extension properly, I should be able to provide
      # the binaries it wants and disable the auto download thing
      # <https://github.com/vadimcn/vscode-lldb/issues/310>
      pkgs.vscode-extensions.vadimcn.vscode-lldb # wrapped by nixpkgs
    ];

  programs.vscode.userSettings = {
    "[rust]" = {
      "editor.fontLigatures" = true;

      "editor.formatOnSave" = true;

      "editor.defaultFormatter" = "rust-lang.rust-analyzer";
    };

    "[slint]" = { "editor.tabSize" = 2; };

    # use clippy over cargo check
    "rust-analyzer.check.command" = "clippy";

    # Set the name of the binary so that it does not use a bundle.
    # This is useful because `nix develop` should provide `rust-analyzer`,
    # and when it doesn't, it will use the one from `home.packages`.
    "rust-analyzer.server.path" = "rust-analyzer";

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

    # show lens text above attributes
    "rust-analyzer.lens.location" = "above_whole_item";

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
