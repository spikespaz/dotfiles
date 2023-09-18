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
        let prettyName = "${lib.concatStringsSep "." path} :: ${name}";
        in if fail then
          builtins.trace ''
            ${prettyName}

            got: ${got}

            expected: ${expected}
          '' prettyName
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
          count = lib.length tests;
          bad = lib.length fails;
          ok = count - bad;
          ratio = (bad + 0.0) / ok;
        in lib.trace ''
          FAILURES: ${toString bad}/${toString ok} (${lib.toPercent 2 ratio})
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
