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

  mkTestSuite = sections: {
    _type = "tests";
    tests = lib.flatten (lib.mapAttrsToList
      (name: tests: map (test: test // { path = [ name ]; }) tests) sections);
  };

  isTestSuite = x: lib.isAttrs x && x ? _type && x._type == "tests";
in { # #
  inherit runTests mkTestSuite isTestSuite;
}
