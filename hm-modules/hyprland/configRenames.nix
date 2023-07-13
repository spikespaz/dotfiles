{ lib, ... }:
let
  mkPathValue = path: name: value: {
    path = path ++ [ name ];
    inherit value;
  };

  # Turn a recursive attrset into a list of
  # `{ path = [...]; value = ...; }` where `path` and `value` are analogous
  # to a name value pair.
  attrsToPathValueList = let
    recurse = path: attrs:
      lib.flatten (lib.mapAttrsToList (name: value:
        if lib.isAttrs value then
          (recurse (path ++ [ name ]) value)
        else
          mkPathValue path name value) attrs);
  in recurse [ ];

  # Inverse operation for `attrsToPathValueList`.
  pathValueListToAttrs = lib.foldl' (acc: attr:
    lib.recursiveUpdate acc (lib.setAttrByPath attr.path attr.value)) { };

  # Given two lists, `from` and `two` where both is a list of
  # attrpaths (list of keys), and an attrset.
  # Create a new attrset where every value corresponding to a path listed in
  # the `from` list is transposed to a new attribute path provided by
  # the value at the corresponding index of `to`.
  renameAttrs = from: to: attrs:
    lib.throwIfNot (builtins.length from == builtins.length to) ''
      expected renameAttrs from and to params to be same length
    '' (lib.pipe attrs [
      attrsToPathValueList
      (map (attr:
        let idx = lib.indexOf attr.path from;
        in if idx == null then
          attr
        else {
          path = builtins.elemAt to idx;
          inherit (attr) value;
        }))
      pathValueListToAttrs
    ]);
in {
  inherit renameAttrs;

  renames = (l: {
    from = lib.catAttrs "prefer" l;
    to = lib.catAttrs "original" l;
  }) [
    {
      prefer = [ "exec_once" ];
      original = [ "exec-once" ];
    }
    {
      prefer = [ "general" "gaps_inside" ];
      original = [ "general" "gaps_in" ];
    }
    {
      prefer = [ "general" "gaps_outside" ];
      original = [ "general" "gaps_out" ];
    }
    {
      prefer = [ "general" "active_border_color" ];
      original = [ "general" "col.active_border" ];
    }
    {
      prefer = [ "general" "inactive_border_color" ];
      original = [ "general" "col.inactive_border" ];
    }
    {
      prefer = [ "general" "active_group_border_color" ];
      original = [ "general" "col.group_border_active" ];
    }
    {
      prefer = [ "general" "inactive_group_border_color" ];
      original = [ "general" "col.group_border" ];
    }
    {
      prefer = [ "decoration" "active_shadow_color" ];
      original = [ "decoration" "col.shadow" ];
    }
    {
      prefer = [ "decoration" "inactive_shadow_color" ];
      original = [ "decoration" "col.shadow_inactive" ];
    }
    {
      prefer = [ "input" "touchpad" "tap_to_click" ];
      original = [ "input" "touchpad" "tap-to-click" ];
    }
    {
      prefer = [ "input" "touchpad" "tap_and_drag" ];
      original = [ "input" "touchpad" "tap-and-drag" ];
    }
    {
      prefer = [ "gestures" "workspace_swipe" "enable" ];
      original = [ "gestures" "workspace_swipe" ];
    }
    {
      prefer = [ "gestures" "workspace_swipe" "fingers" ];
      original = [ "gestures" "workspace_swipe_fingers" ];
    }
    {
      prefer = [ "gestures" "workspace_swipe" "distance" ];
      original = [ "gestures" "workspace_swipe_distance" ];
    }
    {
      prefer = [ "gestures" "workspace_swipe" "invert" ];
      original = [ "gestures" "workspace_swipe_invert" ];
    }
    {
      prefer = [ "gestures" "workspace_swipe" "min_speed_to_force" ];
      original = [ "gestures" "workspace_swipe_min_speed_to_force" ];
    }
    {
      prefer = [ "gestures" "workspace_swipe" "cancel_ratio" ];
      original = [ "gestures" "workspace_swipe_cancel_ratio" ];
    }
    {
      prefer = [ "gestures" "workspace_swipe" "create_new" ];
      original = [ "gestures" "workspace_swipe_create_new" ];
    }
    {
      prefer = [ "gestures" "workspace_swipe" "forever" ];
      original = [ "gestures" "workspace_swipe_forever" ];
    }
    {
      prefer = [ "gestures" "workspace_swipe" "numbered" ];
      original = [ "gestures" "workspace_swipe_numbered" ];
    }
    {
      prefer = [ "misc" "variable_framerate" ];
      original = [ "misc" "vfr" ];
    }
    {
      prefer = [ "misc" "variable_refresh" ];
      original = [ "misc" "vrr" ];
    }
  ];
}
