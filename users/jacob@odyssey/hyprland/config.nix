{ lib, ... }: {
  wayland.windowManager.hyprland.config = {
    xwayland.force_zero_scaling = true;
    # xwayland.use_nearest_neighbor = true;

    input.touchpad = {
      scroll_factor = 0.75;
      # only enabled because tap_and_drag
      # doesn't work without it
      tap_to_click = true;
      tap_and_drag = true;
      # one, two, or three finger clicks
      clickfinger_behavior = true;
    };

    gestures.workspace_swipe = { min_speed_to_force = lib.mkForce 10; };
  };
}
