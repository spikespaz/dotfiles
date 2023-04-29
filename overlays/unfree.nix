lib: paths: pkgs:
let
  mkUnfreeOverlay = pkgs: paths:
    lib.pipe paths [
      (map (path: {
        inherit path;
        value = lib.getAttrFromPath path pkgs;
      }))
      (map (it:
        lib.setAttrByPath it.path (it.value.overrideAttrs (old:
          lib.recursiveUpdate old {
            meta.license = (if builtins.isList old.meta.license then
              map (_: { free = true; }) old.meta.license
            else {
              free = true;
            });
          }))))
      (lib.foldl' lib.recursiveUpdate { })
    ];
in mkUnfreeOverlay pkgs paths
