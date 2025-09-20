{ lib, stdenv, zig }:
stdenv.mkDerivation {
  name = "libprocname-shim.so";
  src = ./procname_shim.zig;
  dontUnpack = true;
  nativeBuildInputs = [ zig.hook ];
  buildPhase = ''
    zig build-lib -dynamic -fPIC -O ReleaseFast -femit-bin=libprocname-shim.so $src -ldl -lpthread
  '';
  installPhase = ''
    install -m0644 libprocname-shim.so $out
  '';
  meta = {
    description = ''
      LD_PRELOAD shim to lock Linux process (comm) name for main thread
    '';
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
  };
}
