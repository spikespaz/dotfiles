{ lib, pkgs, ... }: {
  # I can't think why you wouldn't want application key bindings resolved by
  # the input sym codes. Maybe there was some historical accident that caused
  # this
  wayland.windowManager.hyprland.config = {
    input.resolve_binds_by_sym = true;
  };

  wayland.windowManager.hyprland.deviceConfig = {
    "at-translated-set-2-keyboard" = {
      kb_layout = "us,us";
      kb_variant = "colemak_dh,";
      kb_options = "caps:ctrl_modifier,";
    };
  };
}
