{ lib }:
let
  makePrettyName = { path, name, ... }:
    "${lib.concatStringsSep "." path} :: ${name}";

  evalTest = { path, name, expr, expect }: {
    inherit path name;
    passed = expr == expect;
    evaluated = lib.generators.toPretty { multiline = true; } expr;
    expected = lib.generators.toPretty { multiline = true; } expect;
  };

  runTestsRecursive = expr: args:
    lib.pipe expr [
      (expr: importTests expr args)
      (collectTests [ ] [ ])
      (map evalTest)
      (results: {
        successes = lib.filter (res: res.passed) results;
        failures = lib.filter (res: !res.passed) results;
      })
      ({ successes, failures }:
        let
          succeeded = lib.length successes;
          # Folding sum has been used to force failures down the eval path,
          # so that traces can be displayed.
          failed = lib.foldl' (count: result:
            lib.trace ''
              ${makePrettyName result}
              evaluated: ${result.evaluated}
              expected: ${result.expected}
            '' (count + 1)) 0 failures;
          total = succeeded + failed;
          ratio = (failed + 0.0) / total;
        in lib.trace ''
          TOTAL FAILURES: ${toString failed}/${toString total} (${
            lib.toPercent 2 ratio
          })

          ${lib.concatImapStrings (i: res: (''
            ${toString i}: ${makePrettyName res}
          '')) failures}
        '' failures)
      (failures:
        if builtins.length failures == 0 then
          true
        else
        # Force all failures to be evaluated, aborting with error code for CI.
          assert (builtins.all (_: false) failures); false)
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

  # Walk down a recursive attribute set (produced by `importTests`),
  # collecting all tests into a final list.
  # The list preserves the attribute path in `path` of each test.
  collectTests = acc: path: attrs:
    if lib.birdos.isTestSuite attrs then
      acc ++ map (test: test // { path = path ++ test.path; }) attrs.tests
    else
      lib.flatten
      (lib.mapAttrsToList (name: collectTests acc (path ++ [ name ])) attrs);
in { # #
  inherit evalTest runTestsRecursive mkTestSuite isTestSuite importTests
    collectTests;
}
