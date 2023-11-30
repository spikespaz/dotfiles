{ lib, ... }: {
  wayland.windowManager.hyprland.config = {
    xwayland.force_zero_scaling = true;

    gestures.workspace_swipe = { min_speed_to_force = lib.mkForce 10; };
  };
}
