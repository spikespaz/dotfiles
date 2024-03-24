# Import this file and use it as a Home Manager module.
# Specify the arguments as desired (for each host, preferably).
pkgs:
{
# If the flake is cloned into a bare repository.
flakeIsWorktree ? false
  # The basename of the flake repository's path.
, flakeBasename
# If you have a working tree for each host in the flake, inside the bare repository.
# The current hostname will be used as the name of the working tree to build.
, flakeHostBranches ? flakeIsWorktree
  # Manual override of the working tree directory's basename.
  # The default is determined by the script.
, flakeWorktreeBranch ? null
  # The final directory of the flake repository after inferring from options
  # described above. Those options describe the scheme, this path is the result.
  # You can choose to override it per-machine if you wish.
  # The default is determined by the script.
, flakeDir ? null
  #
}:
let inherit (pkgs) lib;
in {
  home.packages = [
    (pkgs.patchShellScript ./dots.sh rec {
      name = "dots";
      destination = "/bin/${name}";
      # Recommended to use the `inputs.home-manager` overlay.
      runtimeInputs = [ pkgs.home-manager ];
      overrideEnvironment = {
        NIXOS_FLAKE_IS_WORKTREE = flakeIsWorktree;
        NIXOS_FLAKE_BASENAME = flakeBasename;
        NIXOS_FLAKE_HOST_BRANCHES = flakeHostBranches;
      } // lib.optionalAttrs (flakeWorktreeBranch != null) {
        NIXOS_FLAKE_WORKTREE_BRANCH = flakeWorktreeBranch;
      } // lib.optionalAttrs (flakeDir != null) { NIXOS_FLAKE_DIR = flakeDir; };
    })
  ];
}
