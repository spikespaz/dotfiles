self: args @ { config, lib, pkgs, ... }: let
  description = "An alternative to the Home Manager ZSH module.";
  cfg = config.programs.zsh-uncruft;
in {
  options = let
    inherit (lib) types;
  in {
    programs.zsh-uncruft = {
      enable = lib.mkEnableOption description;

      zdotdir = lib.mkOption {
        type = types.str;
        default = "${config.xdg.configHome}/zsh";
        example = "";
        description = lib.mdDoc ''
          <https://zsh.sourceforge.io/Doc/Release/Files.html#Files>
        '';
      };

      zshenv = lib.mkOption {
        type = types.str;
        default = "";
        example = "";
        description = lib.mdDoc "TODO";
      };

      zprofile = lib.mkOption {
        type = types.str;
        default = "";
        example = "";
        description = lib.mdDoc "TODO";
      };

      zshrc = lib.mkOption {
        type = types.str;
        default = "";
        example = "";
        description = lib.mdDoc "TODO";
      };

      zlogin = lib.mkOption {
        type = types.str;
        default = "";
        example = "";
        description = lib.mdDoc "TODO";
      };

      zlogout = lib.mkOption {
        type = types.str;
        default = "";
        example = "";
        description = lib.mdDoc "TODO";
      };

      # options = lib.submodule (import ./options.nix args);

      # znap = lib.submodule (import ./znap.nix args);
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    { home.packages = [ pkgs.zsh ]; }

    # there is still one file that must exist in the user's home,
    # simply defer to the custom `.zshenv` in their `$ZDOTDIR`
    {
      home.file."${config.home.homeDirectory}/.zshenv".text = lib.mkBefore ''
        export ZDOTDIR='${cfg.zdotdir}'
        source '${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh'
        source '${cfg.zdotdir}/.zshenv'
      '';
    }

    (lib.mkIf (cfg.zshenv != "") {
      home.file."${cfg.zdotdir}/.zshenv".text = cfg.zshenv;
    })

    (lib.mkIf (cfg.zprofile != "") {
      home.file."${cfg.zdotdir}/.zprofile".text = cfg.zprofile;
    })

    (lib.mkIf (cfg.zshrc != "") {
      home.file."${cfg.zdotdir}/.zshrc".text = cfg.zshrc;
    })

    (lib.mkIf (cfg.zlogin != "") {
      home.file."${cfg.zdotdir}/.zlogin".text = cfg.zlogin;
    })

    (lib.mkIf (cfg.zlogout != "") {
      home.file."${cfg.zdotdir}/.zlogout".text = cfg.zlogout;
    })
  ]);
}
