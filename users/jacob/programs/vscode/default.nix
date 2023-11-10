{ lib, ... }: {
  settings = import ./settings.nix;
  languages = lib.importDir' ./languages null;
  other = lib.importDir' ./other null;
}
