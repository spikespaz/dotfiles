{ lib }:
let
  runTests = _: path: tests:
    lib.pipe tests [
      (lib.mapListToAttrs ({ name, expr, expect }: {
        name = "${lib.concatStringsSep "." path} :: ${name}";
        value = {
          inherit name path;
          success = expr == expect;
          fail = expr != expect;
          got = lib.generators.toPretty { multiline = true; } expr;
          expected = lib.generators.toPretty { multiline = true; } expect;
        };
      }))
      (lib.mapAttrsToList (name:
        { fail, got, expected, ... }:
        if fail then
          builtins.trace ''
            ${name}

            got: ${got}

            expected: ${expected}
          '' name
        else
          null))
      (lib.filter (name: name != null))
      (fails:
        let
          ok = (lib.length tests) - bad;
          bad = lib.length fails;
          per = (bad / ok) * 100.0;
        in lib.trace ''

          SUCCESSFUL: ${toString ok}
          FAILURES: ${toString bad} (${toString (per)}%)
        '' fails)
    ];

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
  inherit runTests mkTests mkTestSuite runTestsRecursive;
}
