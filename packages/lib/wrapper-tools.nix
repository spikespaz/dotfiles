{ makeSetupHook, writeScript, writeText, runtimeShell }:
let
  hookScript = writeScript "wrapper-tools-setup-hook.in" ''
    #!@shell@

    customWrapper() {
      local prog="$1"
      local wrapper="$2"
      local hidden

      assertExecutable "$prog"

      hidden="$(dirname "$prog")/.$(basename "$prog")-wrapped"
      while [ -e "$hidden" ]; do
        hidden+='_'
      done
      mv "$prog" "$hidden"

      cp "$wrapper" "$prog"
      chmod +x "$prog"
      patchShebangs "$prog"
      substituteInPlace "$prog" \
        --subst-var-by 'shell' '@shell@' \
        --subst-var-by 'helpers' '@helpers@' \
        --subst-var-by 'program' "$hidden"
    }
  '';
  helperScript = writeText "wrapper-tools-helpers" ''
    # shellcheck shell=bash

    # This script is not intended to be run standalone.
    # Use the `source` command in your custom wrapper
    # to gain access to these functions.

    trimPath() {
      local var="$1"
      local sep="$2"
      eval "$var=\"\''${$var%$sep}\""
      eval "$var=\"\''${$var#$sep}\""
    }

    prefixPath() {
      local var="$1"
      local sep="$2"
      local value="$3"
      eval "$var='$value$sep'\"\$$var\""
      trimPath "$var" "$sep"
    }

    suffixPath() {
      local var="$1"
      local sep="$2"
      local value="$3"
      eval "$var+='$sep$value'"
      trimPath "$var" "$sep"
    }
  '';
in makeSetupHook {
  name = "custom-wrapper-hook";
  substitutions = {
    shell = runtimeShell;
    helpers = helperScript;
  };
  passthru.helpers = helperScript;
} hookScript
