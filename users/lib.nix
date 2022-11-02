lib: rec {
  mkMimeApps = associations: {
    xdg.mimeApps = let
      flipAssoc = n: v: map (x: {"${x}" = "${n}.desktop";}) v;
      associations' = lib.pipe associations [
        (lib.mapAttrsToList flipAssoc)
        lib.flatten
        lib.zipAttrs
      ];
    in {
      enable = true;
      associations.added = associations';
      defaultApplications = associations';
    };
  };
}
