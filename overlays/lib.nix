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
      mainProgram = let match = (builtins.match "/bin/([^/]+)" destination);
      in if match == null then null else lib.elemAt match 0;
    in pkgs.stdenvNoCC.mkDerivation (self:
      {
        pname = name;
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
      }) // lib.optionalAttrs (mainProgram != null) {
        meta = { inherit mainProgram; } // meta;
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

  patchNuScript = script:
    args@{ name ? baseNameOf script, strictDeps ? true, runtimeInputs ? [ ]
    , destination ? "", overrideEnvironment ? { }, checkPhase ? null
    , runLocal ? true, meta ? { }, passAsFile ? [ ], ... }:
    let
      toNu = v:
        ''("${lib.escape [ ''"'' "\\" ] (builtins.toJSON v)}" | from json)'';
      makeBinPathArray = packages:
        let
          binOutputs = builtins.filter (x: x != null) (map lib.getBin packages);
        in "[" + lib.concatMapStringsSep "," (p: ''"${p}/bin"'') binOutputs
        + "]";

      ownArgs = builtins.attrNames (lib.functionArgs (patchShellScript null));
      derivationArgs = removeAttrs args ownArgs;
      mainProgram = let match = (builtins.match "/bin/([^/]+)" destination);
      in if match == null then null else lib.elemAt match 0;
    in pkgs.stdenvNoCC.mkDerivation (self:
      {
        pname = name;
        inherit name strictDeps;

        enableParallelBuilding = true;

        passAsFile = [ "text" "buildCommand" ] ++ passAsFile;

        text = ''
          #!${pkgs.nushell}/bin/nu
        '' + lib.optionalString (runtimeInputs != [ ]) ''

          $env.PATH = ${makeBinPathArray runtimeInputs} ++ $env.PATH
        '' + lib.optionalString (overrideEnvironment != { }) ''

          load-env ${toNu overrideEnvironment}
        '' + ''

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
      }) // lib.optionalAttrs (mainProgram != null) {
        meta = { inherit mainProgram; } // meta;
      } // lib.optionalAttrs (checkPhase != null) {
        checkPhase = ''
          ${pkgs.stdenvNoCC.shellDryRun} "$target"
          ${pkgs.nushell}/bin/nu --commands "nu-check --debug '$target'"
        '';
      } // derivationArgs;

  # Build a Firefox extension from an XPI file...
  buildFirefoxXpiAddon = lib.makeOverridable ({
    # Required:
    pname, version, addonId, url, hash, meta,
    # Override:
    stdenv ? pkgs.stdenv, fetchurl ? pkgs.fetchurl,
    #
    ... }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url hash; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    });
in { # #
  inherit patchShellScript patchNuScript buildFirefoxXpiAddon;
}
