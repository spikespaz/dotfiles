let
  module = path: {
    programs.vscode.enable = true;
    imports = [path];
  };
  withAllModule = attrs:
    attrs
    // {
      all.imports = builtins.attrValues (removeAttrs attrs ["all"]);
    };
in
  withAllModule {
    settings = module ./settings.nix;

    languages = withAllModule {
      bash = module ./languages/bash.nix;
      nix = module ./languages/nix.nix;
      perl = module ./languages/perl.nix;
      rust = module ./languages/rust.nix;
    };
  }
