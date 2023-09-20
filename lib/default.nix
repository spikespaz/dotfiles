lib: lib0:
let
  libAttrs =
    lib.mapAttrs (_: fn: fn { inherit lib; }) (lib.importDir ./. "default.nix");
in lib0 // {
  birdos = {
    lib = libAttrs;
    inherit (libAttrs) colors;
  };

  maintainers.spikespaz = {
    email = "jacob@birkett.dev";
    github = "spikespaz";
    githubId = "MDQ6VXNlcjEyNTAyOTg4";
    name = 12502988;
  };
}
