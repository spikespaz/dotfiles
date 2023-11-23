# Thank you to <https://nixbuild.net> for a great build service,
# and <https://cachix.org> for their public service as well.
#
# Must use the user identity for interacting with the shell while building:
# $ ssh -i ~/.ssh/id_ed25519 eu.nixbuild.net shell
# Otherwise, it will use the host key first and be denied if the daemon
# is connected to the remote already using that key.
{ lib, pkgs, ... }:
(xs: { imports = xs; }) [
  {
    # the publoic key of this host must be added to nixbuild's
    # settings using the configuration shell
    programs.ssh.extraConfig = ''
      Host eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        IdentityFile /etc/ssh/ssh_host_ed25519_key
    '';

    programs.ssh.knownHosts = {
      nixbuild = {
        hostNames = [ "eu.nixbuild.net" ];
        publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
    };

    nix = {
      # use nixbuild builders for the specified platforms
      distributedBuilds = lib.mkDefault true;
      buildMachines = let
        # nixbuild requires that each system is a separate builder,
        # presumably they have dedicated hardware or virtual machines
        systems = [ "x86_64-linux" "aarch64-linux" "armv7l-linux" ];
      in map (system: {
        hostName = "eu.nixbuild.net";
        supportedFeatures = [ "benchmark" "big-parallel" ];
        maxJobs = 100; # supposedly ignored
        inherit system;
      }) systems;
      # allow the remote to use substituters (set up with the shell)
      settings.builders-use-substitutes = true;
      # nixbuild is also used as a substituter for this machine,
      # in case we need packages before they upload to cachix (intrepid)
      settings.extra-substituters = [ "ssh://eu.nixbuild.net" ];
      settings.extra-trusted-public-keys = [
        "nixbuild.net/spikespaz@outlook.com-1:gvbfrV9++PLNx1aSR+hvWJ126Zy5KY/vIfo+zQ3eUOg="
      ];
    };
  }
  # this is also my own public cachix instance,
  # which nixbuild will upload completed builds to
  {
    nix.settings = {
      extra-substituters = [ "https://intrepid.cachix.org" ];
      extra-trusted-public-keys = [
        "intrepid.cachix.org-1:6K2f96UHKQt9ceQ7o2fYi4TdCY4K5Y1V/MXk1WI8X5o="
      ];
    };

    # include the cachix CLI as a system package for good measure
    environment.systemPackages = [ pkgs.cachix ];
  }
]
