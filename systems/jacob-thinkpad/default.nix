{ nixpkgs, pkgs, modules }:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";

  specialArgs = {
    inherit modules;
    enableUnstableZfs = false;
  };

  modules = [
    { nixpkgs.pkgs = pkgs; }
    # <https://github.com/NixOS/nixos-hardware/blob/master/lenovo/thinkpad/p14s/amd/gen2/default.nix>
    modules.lenovo-thinkpad-p14s-amd-gen2
    ./filesystems.nix
    ./configuration.nix
    ./powersave.nix
    ./touchpad.nix
    ./greeter.nix
  ];
}
