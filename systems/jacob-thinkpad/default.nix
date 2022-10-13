{
  self,
  nixpkgs,
  pkgs,
  modules,
}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  inherit pkgs;

  specialArgs = {
    inherit self modules;
    enableUnstableZfs = false;
  };

  modules = [
    ./filesystems.nix
    ./configuration.nix
    ./powersave.nix
    ./touchpad.nix
    ./greeter.nix
  ];
}
