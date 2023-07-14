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

  mkTestSuite = args:
    let
      args' = if args ? lib then args else args // { inherit lib; };
      coerce = expr:
        if lib.isPath expr then
          coerce (import expr)
        else if lib.isFunction expr then
          let fnArgs = builtins.functionArgs expr;
          in expr (builtins.intersectAttrs fnArgs args')
        else
          expr;
    in lib.mapAttrsRecursive (_: coerce);

  runTestsRecursive = recursiveTests:
    lib.mapAttrsRecursiveCond (attrs: (lib.getAttr "_type" attrs) != "tests")
    (path: tests: lib.runTests tests) recursiveTests;
in {
  #
  inherit mkTests mkTestSuite runTestsRecursive;
}
