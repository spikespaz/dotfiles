self: { config, lib, pkgs, ... }: let
  description = ''
    An alternative to the Home Manager ZSH module.
  '';
  cfg = config.programs.zsh-uncruft;
in {
  imports = [
    ./znap.nix
  ];

  options = let
    inherit (lib) types;
  in {
    programs.zsh-uncruft = {
      enable = lib.mkEnableOption description;

      zdotdir = lib.mkOption {
        type = types.str;
        default = "${config.xdg.configHome}/zsh";
        example = lib.literalExpression ''
          ${config.xdg.configHome}/zsh
        '';
        description = lib.mdDoc ''
          <https://zsh.sourceforge.io/Doc/Release/Files.html>
        '';
      };

      zshenv = lib.mkOption {
        type = types.str;
        default = "";
        example = lib.literalExpression ''
          "TODO"
        '';
        description = lib.mdDoc ''
          TODO
        '';
      };

      zprofile = lib.mkOption {
        type = types.str;
        default = "";
        example = lib.literalExpression ''
          "TODO"
        '';
        description = lib.mdDoc ''
          TODO
        '';
      };

      zshrc = lib.mkOption {
        type = types.str;
        default = "";
        example = lib.literalExpression ''
          "TODO"
        '';
        description = lib.mdDoc ''
          TODO
        '';
      };

      zlogin = lib.mkOption {
        type = types.str;
        default = "";
        example = lib.literalExpression ''
          "TODO"
        '';
        description = lib.mdDoc ''
          TODO
        '';
      };

      zlogout = lib.mkOption {
        type = types.str;
        default = "";
        example = lib.literalExpression ''
          "TODO"
        '';
        description = lib.mdDoc ''
          TODO
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    { home.packages = [ pkgs.zsh ]; }

    {
      # there is still one file that must exist in the user's home,
      # simply defer to the custom `.zshenv` in their `$ZDOTDIR`
      # the merge is made with `mkBefore` to ensure that if the user specifies
      # another `.text` for this `home.file`, it will be inserted after
      home.file."${config.home.homeDirectory}/.zshenv".text = lib.mkBefore ''
        export ZDOTDIR='${cfg.zdotdir}'
        source '${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh'
      '';
    }

    (lib.mkIf (cfg.zshenv != "") {
      # if the user specifies custom text for their `.zshenv` in `$ZDOTDIR`,
      # source that at the end of the required bootstrapping one.
      # this is at the end of the bootstrapper because a user may want
      # to insert text with an option that is not provided by this module.
      home.file."${config.home.homeDirectory}/.zshenv".text = lib.mkAfter ''
        source '${cfg.zdotdir}/.zshenv'
      '';
      home.file."${cfg.zdotdir}/.zshenv".text = cfg.zshenv;
    })

    (lib.mkIf (cfg.zprofile != "") {
      home.file."${cfg.zdotdir}/.zprofile".text = cfg.zprofile;
    })

    (lib.mkIf (cfg.zshrc != "") {
      home.file."${cfg.zdotdir}/.zshrc".text = lib.mkOrder 1000 cfg.zshrc;
    })

    (lib.mkIf (cfg.zlogin != "") {
      home.file."${cfg.zdotdir}/.zlogin".text = cfg.zlogin;
    })

    (lib.mkIf (cfg.zlogout != "") {
      home.file."${cfg.zdotdir}/.zlogout".text = cfg.zlogout;
    })
  ]);
}
