{ lib }:
let
  not = a: !a;
  # `and` defined in `lib.trivial`
  nand = a: b: !(a && b);
  # `or` defined in `lib.trivial`
  nor = a: b: !(a || b);
  xor = a: b: (a || b) && !(a && b);
  xnor = a: b: !(a || b) || (a && b);

  # logical implication,
  # compates c to falsy values, if falsy
  # use d otherwise evaluate v
  imply = c: v: implyDefault c null v;
  implyDefault = c: d: v:
    if (c == null) || c == false || c == { } || c == [ ] || c == "" || c
    == 0 then
      d
    else
      v;

  applyArgs = lib.foldl' (fn': arg: fn' arg);

  # Given a large attribute set (of arguments),
  # reduce the set to only what the function expects, and apply it.
  applyAutoArgs = fn: attrs:
    let
      fnArgs = lib.functionArgs fn;
      autoArgs = builtins.intersectAttrs fnArgs attrs;
    in fn autoArgs;
in {
  #
  inherit not nand nor xor xnor imply implyDefault applyArgs applyAutoArgs;
}
