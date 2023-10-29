pkgs: pkgs0:
let inherit (pkgs) lib;
in {
  # Alacritty 0.12.3 has a problem with latest Hyprland:
  #
  # ```
  # Error: provided display handle is not supported
  # warning: queue 0x7fd10c000ca0 destroyed while proxies still attached:
  #   zwp_primary_selection_device_v1@27 still attached
  #   zwp_primary_selection_device_manager_v1@23 still attached
  #   wl_data_device@26 still attached
  #   wl_seat@25 still attached
  #   wl_data_device_manager@24 still attached
  #   wl_registry@22 still attached
  # warning: queue 0x55a9a5d34100 destroyed while proxies still attached:
  #   wl_output@17 still attached
  #   wl_output@16 still attached
  #   wl_output@15 still attached
  #   wp_fractional_scale_manager_v1@14 still attached
  #   xdg_activation_v1@13 still attached
  #   zwp_text_input_manager_v3@12 still attached
  #   zwp_relative_pointer_manager_v1@11 still attached
  #   zwp_pointer_constraints_v1@10 still attached
  #   zxdg_decoration_manager_v1@9 still attached
  #   wl_seat@8 still attached
  #   wp_viewporter@7 still attached
  #   wl_subcompositor@6 still attached
  #   wl_compositor@5 still attached
  #   wl_shm@4 still attached
  #   wl_registry@2 still attached
  # Error: "Event loop terminated with code: 1"
  # ```
  alacritty = pkgs0.alacritty.overrideAttrs (self: super: {
    version = "unstable-2023-10-28";
    src = pkgs.fetchFromGitHub {
      owner = "alacritty";
      repo = "alacritty";
      rev = "0db2fc7865cff5c7455889093042329b9f5ef68c";
      hash = "sha256-dmJP95XYskGNI4s+scywp3n62O420a79uUaDRz6zFeM=";
    };
    cargoDeps = super.cargoDeps.overrideAttrs {
      inherit (self) src;
      outputHash = "sha256-L5w82ajfbDkHNX9VEq9eev71SbftULjXYYHbYZiZmJE=";
    };
    nativeBuildInputs = super.nativeBuildInputs ++ [ pkgs.scdoc ];
    postInstall = lib.concatStrings [
      # The manpages have been moved to scdoc, but the derivation
      # expects these files to exist. Create blank files so that the gzip
      # command doesn't fail the build
      ''
        touch extra/alacritty.man
        touch extra/alacritty-msg.man
      ''
      # The sample configuration file has been removed and is not only
      # documented in the manpages.
      ''
        touch alacritty.yml
      ''
      super.postInstall
      # These are the real manpages that need to be copied.
      ''
        scdoc < extra/man/alacritty.1.scd | gzip -c > "$out/share/man/man1/alacritty.1.gz"
        scdoc < extra/man/alacritty-msg.1.scd | gzip -c > "$out/share/man/man1/alacritty-msg.1.gz"
      ''
      # This file is empty because it is no longer included since 0.13.0.
      ''
        rm $out/share/doc/alacritty.yml
      ''
    ];
  });
}
