lib: lib0:
let
  libAttrs =
    lib.mapAttrs (_: fn: fn { inherit lib; }) (lib.importDir ./. "default.nix");
in lib0 // {
  birdos = {
    lib = libAttrs;
    inherit (libAttrs) colors;

    parseUserAtHost = userAtHost:
      let
        groups =
          builtins.match "([a-zA-Z][a-zA-Z0-9_-]+)@([a-zA-Z][a-zA-Z0-9_-]+)"
          userAtHost;
      in if builtins.length groups != 2 then
        null
      else {
        user = builtins.elemAt groups 0;
        host = builtins.elemAt groups 1;
      };
  };

  systems = lib0.systems // {
    architectures = lib0.systems.architectures // {
      featureSupport = arch:
        lib.mapAttrs (_: f: f arch) lib.systems.architectures.predicates;
    };
  };

  maintainers.spikespaz = {
    email = "jacob@birkett.dev";
    github = "spikespaz";
    githubId = "MDQ6VXNlcjEyNTAyOTg4";
    name = 12502988;
  };
}
