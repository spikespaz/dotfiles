{
  nixpkgs,
  pkgs,
  modules,
}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";

  specialArgs = {
    inherit modules;
    enableUnstableZfs = false;
  };

  modules = [
    {nixpkgs.pkgs = pkgs;}
    ./filesystems.nix
    ./configuration.nix
    ./powersave.nix
    ./touchpad.nix
    ./greeter.nix
  ];
}
