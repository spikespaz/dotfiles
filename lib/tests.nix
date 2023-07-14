{ lib }:
let
  mkTests = tests:
    assert lib.assertMsg (!tests ? _type)
      "the attribute `_type` may not be used with `mkTests`";
    assert lib.assertMsg (!tests ? tests)
      "the attribute `tests` may not be used with `mkTests` because it conflicts with effects of attribute `disable`";
    (if tests ? disable then
      removeAttrs tests (tests.disable ++ [ "disable" ])
    else
      tests) // {
        _type = "tests";
        tests = builtins.attrNames tests;
      };

  runTestsRecursive = recursiveTests:
    lib.mapAttrsRecursiveCond (attrs: (lib.getAttr "_type" attrs) != "tests")
    (path: tests: lib.runTests tests) recursiveTests;
in {
  #
  inherit mkTests runTestsRecursive;
}
