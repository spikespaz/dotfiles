lib: packageOverlays:
lib.updates [
  # Include all overlays from the current directory
  # (excluding `default.nix` as it is not an overlay).
  (lib.importDir ./. null)
  # Also include each package overlay, as it is named.
  packageOverlays
  {
    # The `default` overlay includes all the packages
    # (and package sets) exported by this flake.
    #
    # The overlay `allowUnfree` is not included by default.
    # This is because the user should be explicitly aware
    # that they are using the "hack".
    default = lib.bird.mkJoinedOverlays (lib.attrValues packageOverlays);

    # This overlay is included as a hack to make the packages (last argument)
    # easier to work with. Proper handling of unfree packages is really confusing,
    # so this is here to make sure there's an easy way to get stuff to work.
    allowUnfree = pkgs: pkgs0:
      lib.bird.mkUnfreeOverlay pkgs0 [ [ "ttf-ms-win11" ] ];
  }
]
