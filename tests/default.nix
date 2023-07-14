{ lib }:
let
  tests = lib.mapAttrsRecursive (_: file: import file { inherit lib; }) {
    lib.lists = ./lib/lists.nix;
  };
in {
  inherit tests;
  results = lib.runTestsRecursive tests;
}
