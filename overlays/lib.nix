pkgs: pkgs0:
let
  inherit (pkgs) lib;

  # I think this is correct, or at least mostly there.
  patchShellScript = script:
    args@{ name ? baseNameOf script, strictDeps ? true, runtimeInputs ? [ ]
    , destination ? "", overrideEnvironment ? { }, checkPhase ? null
    , runLocal ? true, meta ? { }, passAsFile ? [ ], ... }:
    let
      ownArgs = builtins.attrNames (lib.functionArgs (patchShellScript null));
      derivationArgs = removeAttrs args ownArgs;
      matchesBin = builtins.match "/bin/([^/]+)" destination;
    in pkgs.stdenvNoCC.mkDerivation (self:
      {
        inherit name strictDeps;

        enableParallelBuilding = true;

        passAsFile = [ "text" "buildCommand" ] ++ passAsFile;
        text = ''
          #!${pkgs.runtimeShell}

          PATH="${lib.makeBinPath runtimeInputs}:$PATH"
          ${lib.toShellVars overrideEnvironment}

          ${builtins.readFile script}
        '';
        buildCommand = ''
          target=$out${lib.escapeShellArg destination}
          mkdir -p "$(dirname "$target")"

          if [ -e "$textPath" ]; then
            mv "$textPath" "$target"
          else
            echo -n "$text" > "$target"
          fi

          chmod +x "$target"

          eval "$checkPhase"
        '';

      } // lib.optionalAttrs runLocal {
        preferLocalBuild = true;
        allowSubstitutes = false;
      }) // lib.optionalAttrs (matchesBin != null) {
        meta = { mainProgram = lib.head matchesBin; } // meta;
      } // lib.optionalAttrs (checkPhase != null) {
        checkPhase = let
          shellcheckSupported = lib.meta.availableOn pkgs.stdenv.buildPlatform
            pkgs.shellcheck.compiler;
          shellcheck = lib.getExe
            (pkgs.haskell.lib.compose.justStaticExecutables
              pkgs.shellcheck.unwrapped);
        in ''
          ${pkgs.stdenvNoCC.shellDryRun} "$target"
          ${lib.optionalString shellcheckSupported ''${shellcheck} "$target"''}
        '';
      } // derivationArgs;

in { # #
  inherit patchShellScript;
}
