{ lib }:
let
  _traceMsgVal = msg: val: ''
    ${msg}
    ${lib.generators.toPretty { multiline = true; } val}'';

  traceM = m: v: builtins.trace (_traceMsgVal m v);
  traceValM = m: v: builtins.trace (_traceMsgVal m v) v;
in {
  #
  inherit traceM traceValM;
}
