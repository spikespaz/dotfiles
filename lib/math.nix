{ lib }:
let
  # Raise a base to a positive power.
  pow = base: exp: lib.foldl' builtins.mul 1 (lib.replicate exp base);
  # Raise a base to a positive power, and round down (floor).
  powi = base: exp: builtins.floor (pow base exp);
  # Get the fractional part of a floating-point number.
  mantissa = n: n - (builtins.floor n);
  # Absolute value
  abs = num: if num < 0 then -num else num;
in {
  #
  inherit pow powi mantissa abs;
}
