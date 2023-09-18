{ lib }:
let
  # Raise a base to a positive power.
  pow = base: exp: lib.foldl' builtins.mul 1 (lib.replicate exp base);
  # Raise a base to a positive power, and round down (floor).
  powi = base: exp: builtins.floor (pow base exp);
  # Get the fractional part of a floating-point number.
  mantissa = n: n - (builtins.floor n);
  #
  round = decimals: n:
    let
      shift = pow 10.0 decimals;
      shifted = n * shift;
      roundFn =
        if mantissa shifted >= 0.5 then builtins.ceil else builtins.floor;
    in (roundFn shifted) / shift;
  # Absolute value
  abs = num: if num < 0 then -num else num;
in {
  #
  inherit pow powi mantissa round abs;
}
