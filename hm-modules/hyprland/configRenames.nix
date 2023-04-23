{lib, ...}: let
  # Turn a recursive attrset into a list of
  # `{ path = [...]; value = ...; }` where `path` and `value` are analogous
  # to a name value pair.
  attrsToPathValueList = let
    recurse = path: attrs:
      lib.flatten (lib.mapAttrsToList (name: value:
        if lib.isAttrs value
        then (recurse (path ++ [name]) value)
        else {
          path = path ++ [name];
          inherit value;
        })
      attrs);
  in
    recurse [];

  # Inverse operation for `attrsToPathValueList`.
  pathValueListToAttrs = lib.foldl' (
    acc: attr:
      lib.recursiveUpdate acc (lib.setAttrByPath attr.path attr.value)
  ) {};

  # Takes a list of renames and attrs for the hyprland config,
  # and recursively renames attributes accordingly.
  applyAttrRenamesMap = renamesMap: attrs:
    lib.pipe attrs [
      # get a list of `{ path = [...]; value = ...; }`
      attrsToPathValueList
      # rename the `path` of the attrs who need to be renamed
      (map (attr: let
        spec = lib.findFirst (spec: attr.path == spec.prefer) null renamesMap;
      in
        if spec == null
        then attr
        else {
          path = spec.original;
          inherit (attr) value;
        }))
      # back to one attrset
      pathValueListToAttrs
    ];
in {
  inherit applyAttrRenamesMap;

  renamesMap = [
    {
      prefer = ["exec_once"];
      original = ["exec-once"];
    }
    {
      prefer = ["general" "gaps_inside"];
      original = ["general" "gaps_in"];
    }
    {
      prefer = ["general" "gaps_outside"];
      original = ["general" "gaps_out"];
    }
    {
      prefer = ["general" "active_border_color"];
      original = ["general" "col.active_border"];
    }
    {
      prefer = ["general" "inactive_border_color"];
      original = ["general" "col.inactive_border"];
    }
    {
      prefer = ["general" "active_group_border_color"];
      original = ["general" "col.group_border_active"];
    }
    {
      prefer = ["general" "inactive_group_border_color"];
      original = ["general" "col.group_border"];
    }
    {
      prefer = ["decoration" "active_shadow_color"];
      original = ["decoration" "col.shadow"];
    }
    {
      prefer = ["decoration" "inactive_shadow_color"];
      original = ["decoration" "col.shadow_inactive"];
    }
    {
      prefer = ["input" "touchpad" "tap_to_click"];
      original = ["input" "touchpad" "tap-to-click"];
    }
    {
      prefer = ["gestures" "workspace_swipe" "enable"];
      original = ["gestures" "workspace_swipe"];
    }
    {
      prefer = ["gestures" "workspace_swipe" "fingers"];
      original = ["gestures" "workspace_swipe_fingers"];
    }
    {
      prefer = ["gestures" "workspace_swipe" "distance"];
      original = ["gestures" "workspace_swipe_distance"];
    }
    {
      prefer = ["gestures" "workspace_swipe" "invert"];
      original = ["gestures" "workspace_swipe_invert"];
    }
    {
      prefer = ["gestures" "workspace_swipe" "min_speed_to_force"];
      original = ["gestures" "workspace_swipe_min_speed_to_force"];
    }
    {
      prefer = ["gestures" "workspace_swipe" "cancel_ratio"];
      original = ["gestures" "workspace_swipe_cancel_ratio"];
    }
    {
      prefer = ["gestures" "workspace_swipe" "create_new"];
      original = ["gestures" "workspace_swipe_create_new"];
    }
    {
      prefer = ["gestures" "workspace_swipe" "forever"];
      original = ["gestures" "workspace_swipe_forever"];
    }
    {
      prefer = ["gestures" "workspace_swipe" "numbered"];
      original = ["gestures" "workspace_swipe_numbered"];
    }
    {
      prefer = ["misc" "variable_framerate"];
      original = ["misc" "vfr"];
    }
    {
      prefer = ["misc" "variable_refresh"];
      original = ["misc" "vrr"];
    }
  ];
}
