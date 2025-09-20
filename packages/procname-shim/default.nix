{ lib, stdenv, zig }:
stdenv.mkDerivation (finalAttrs: {
  pname = "procname-shim";
  name = finalAttrs.pname;
  src = ./procname_shim.zig;
  dontUnpack = true;
  nativeBuildInputs = [ zig.hook ];
  buildPhase = ''
    zig build-lib -dynamic -fPIC -O ReleaseFast -femit-bin=libprocname-shim.so $src -ldl -lpthread
  '';
  installPhase = ''
    install -Dm0644 libprocname-shim.so -t $out/lib/
  '';
  passthru.shim = "${finalAttrs.finalPackage}/lib/libprocname-shim.so";
  meta = {
    description = ''
      LD_PRELOAD shim to lock Linux process (comm) name for main thread
    '';
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
  };
})
