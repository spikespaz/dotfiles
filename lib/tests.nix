{ lib }:
let
  runTest = test:
    lib.pipe test [
      # Evaluate the test.
      ({ path, name, expr, expect }: {
        inherit path name;
        success = expr == expect;
        fail = expr != expect;
        got = lib.generators.toPretty { multiline = true; } expr;
        expected = lib.generators.toPretty { multiline = true; } expect;
      })
      # Trace the test if it failed, return null if successful.
      ({ path, name, fail, got, expected, ... }:
        if fail then
          builtins.trace ''
            "${lib.concatStringsSep "." path} :: ${name}"

            got: ${got}

            expected: ${expected}
          '' name
        else
          null)
    ];

  runTests = tests:
    lib.pipe tests [
      (map runTest)
      # Remove successful tests.
      (lib.filter (name: name != null))
      # Trace the tallies, and return failed tests.
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

  mkTestSuite = sections: {
    _type = "tests";
    tests = lib.flatten (lib.mapAttrsToList
      (name: tests: map (test: test // { path = [ name ]; }) tests) sections);
  };

  isTestSuite = x: lib.isAttrs x && x ? _type && x._type == "tests";
in { # #
  inherit runTests mkTestSuite isTestSuite;
}
