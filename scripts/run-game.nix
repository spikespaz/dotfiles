{ patchShellScript, exeName ? "run-game", util-linux }:
patchShellScript ./run-game.sh rec {
  name = exeName;
  destination = "/bin/${exeName}";
  runtimeInputs = [ util-linux ];
}
