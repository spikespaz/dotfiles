{ lib }:
let
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
in {
  #
  inherit imply implyDefault;
}
