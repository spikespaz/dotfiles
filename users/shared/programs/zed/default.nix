{ pkgs, lib, ... }:
let
  zed-editor' = (let
    super = pkgs.zed-editor;
    fontPackages = with pkgs; [
      material-design-icons
      (nerdfonts.override { fonts = [ "JetBrainsMono" "Monaspace" ]; })
    ];
  in pkgs.symlinkJoin {
    inherit (super) name pname version meta;
    paths = [ super fontPackages ];
    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
    postBuild = ''
      mv $out/bin/${super.meta.mainProgram} $out/bin/zed-editor
      wrapProgram $out/bin/zed-editor \
        --set WAYLAND_DISPLAY ""
      sed -i "s@Exec=zed@Exec=$out/bin/zed-editor@" $out/share/applications/dev.zed.Zed.desktop
    '';
  });
  jsonFormat = pkgs.formats.json { };
in {
  home.packages = [ zed-editor' ];
  xdg.configFile."zed/settings.json".source =
    jsonFormat.generate "zed-settings.json" {
      base_keymap = "VSCode";
      theme = "Zedokai (Filter Spectrum)";
      active_pane_magnification = 1.2;
      autosave = "on_focus_change";
      auto_update = false;
      # buffer_font_family = lib.concatMapStringsSep ", " (s: "'${s}'") [
      #     "Material Design Icons"
      #     "MonaspiceNe Nerd Font"
      #     # "JetBrainsMono Nerd Font"
      # ];
      buffer_font_family = "MonaspiceNe Nerd Font";
      buffer_font_size = 16;
      ui_font_size = 16;

      tabs.git_status = true;
      indent_guides = {
        enabled = true;
        line_width = 1;
        coloring = "indent_aware";
        background_coloring = "indent_aware";
      };
      inlay_hints.enabled = true;
      terminal.shell.with_arguments = {
        program = "zsh";
        args = [ "--login" ];
      };
    };
}
