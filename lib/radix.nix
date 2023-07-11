{ lib }:
let
  intToHex = let
    digits =
      [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b" "c" "d" "e" "f" ];
    accumulate = num: acc:
      if num > 0 then
        (accumulate (num / 16)
          ((builtins.elemAt digits (lib.mod num 16)) + acc))
      else
        acc;
  in num: accumulate num "";
in { inherit intToHex; }
