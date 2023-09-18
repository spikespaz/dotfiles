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
      (lib.filter (res: res != null))
      # Trace the tallies, and return failed tests.
      (fails:
        let
          count = lib.length tests;
          bad = lib.length fails;
          ratio = (bad + 0.0) / count;
        in lib.trace ''
          FAILURES: ${toString bad}/${toString count} (${lib.toPercent 2 ratio})
        '' fails)
    ];

  mkTestSuite = sections: {
    _type = "tests";
    tests = lib.flatten (lib.mapAttrsToList
      (name: tests: map (test: test // { path = [ name ]; }) tests) sections);
  };

  isTestSuite = x: lib.isAttrs x && x ? _type && x._type == "tests";

  # Given a path to a Nix file or directory, or a function,
  # or an attribute set,
  # walk down the tree and try to coerce until
  # the deepest leaves are all test suites.
  #
  # Arguments provided will be surgically applied to any
  # functions encountered, at any level (even top).
  importTests = expr: args:
    if lib.birdos.isTestSuite expr then
    # This is the final step for any attribute set. Recursion ends here.
      expr
    else if lib.types.path.check expr then
    # The expression is a path, or a string that looks like a path.
      if lib.pathIsRegularFile expr then
      # It is a regular file, assumed to be Nix.
      # There is no check because this would only be
      # an issue for the top-level call (user-error).
        importTests (import expr) args
      else if lib.pathIsDirectory expr then
      # The path is a directory, so recurse it.
        lib.pipe (builtins.readDir expr) [
          (lib.mapAttrsToList (lib.mkDirEntry expr))
          # Filter to Nix files, and `default.nix` is unsupported.
          (lib.filter (entry: entry.isNix && !entry.isDefault))
          # A new attribute set is created, with the names of each import.
          (lib.mapListToAttrs (entry: {
            # Directories without `default.nix` are supported
            # (at least, that file is simply ignored),
            # and will be recursed by this very same branch.
            name = if entry.isFile then
              lib.removeSuffix ".nix" entry.name
            else
              entry.name;
            # The imports themselves are recursed by `importTests`,
            # and are expected to match one of the other branches.
            value = importTests entry.path args;
          }))
        ]
      else
        abort "the path type ${lib.pathType expr} cannot be imported"
    else if lib.isFunction expr then
    # It is a function, try importing it by applying arguments surgically.
    # This recurses again so that attribute sets are walked.
      importTests (lib.applyAutoArgs expr args) args
    else if lib.isAttrs expr then
    # If it is a deeper attribute set, and not a test suite,
    # recurse each value.
      lib.mapAttrs (_: value: importTests value args) expr
    else
      abort "value of type ${builtins.typeOf expr} cannot be a test suite";
in { # #
  inherit runTests mkTestSuite isTestSuite importTests;
}
