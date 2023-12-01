{ lib, ... }: {
  wayland.windowManager.hyprland.config = {
    xwayland.force_zero_scaling = true;
    # xwayland.use_nearest_neighbor = true;

    input.touchpad = {
      scroll_factor = 0.75;
      tap_to_click = false;
      tap_and_drag = true;
      clickfinger_behavior = true;
    };

    gestures.workspace_swipe = { min_speed_to_force = lib.mkForce 10; };
  };
}
