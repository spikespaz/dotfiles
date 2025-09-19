{ lib, fetchgit, maven, jdk8 }:
let
  packageBase = { pname, version, src, mvnHash }:
    maven.buildMavenPackage {
      inherit pname version src;
      buildOffline = true;
      mvnJdk = jdk8;
      mvnHash = mvnHash;
      installPhase = ''
        runHook preInstall
        install -Dm644 target/*.jar -t $out
        runHook postInstall
      '';
    };

  pluginBase = { name, version, srcHash, mvnHash }:
    packageBase {
      pname = "ja-netfilter-plugin-${name}";
      src = fetchgit {
        url = "https://gitee.com/ja-netfilter/plugin-${name}.git";
        rev = "v${version}";
        sha256 = srcHash;
      };
      inherit version mvnHash;
    };

  ja-netfilter = packageBase rec {
    pname = "ja-netfilter";
    version = "2022.2.0";
    src = fetchgit {
      url = "https://gitee.com/ja-netfilter/ja-netfilter.git";
      rev = version;
      sha256 = "sha256-jlRJ2r9EnbaqG7tGhJduFCchORdraZL3aTBa1btgMIU=";
    };
    mvnHash = "sha256-qi4j6w8zwszb3vzrehx4UmKyYD0OcKfjlQ7QsDKK8C4=";
  };

  plugins = {
    dns = {
      version = "1.1.0";
      srcHash = "sha256-JSBGjQY7KmO7pcrATY5Ql9eg+hQUHqy9869uINLz+Fo=";
      mvnHash = "sha256-qi4j6w8zwszb3vzrehx4UmKyYD0OcKfjlQ7QsDKK8C4=";
    };
    url = {
      version = "1.1.0";
      srcHash = "sha256-7YiiPDjQr6vN933svHwz1yK3PdWTsY2SeJsw+PBv+zY=";
      mvnHash = "sha256-qi4j6w8zwszb3vzrehx4UmKyYD0OcKfjlQ7QsDKK8C4=";
    };
    hideme = {
      version = "1.1.0";
      srcHash = "sha256-tGAesHIGmdlp2PCTfX5zrikqjD9ZiQ+0tLsJFGiWwPQ=";
      mvnHash = "sha256-qi4j6w8zwszb3vzrehx4UmKyYD0OcKfjlQ7QsDKK8C4=";
    };
    dump = {
      version = "1.0.1";
      srcHash = "";
      mvnHash = "";
    };
    native = {
      version = "1.0.0";
      srcHash = "";
      mvnHash = "";
    };
    power = {
      version = "1.1.0";
      srcHash = "sha256-sTjHvpQYF6soRIDhPspCdLYqLfZwPCjERq1EhIvX9z0=";
      mvnHash = "sha256-Xev7pJdMXw8ArZVAnfQbKxUMKB291+YigNlPOpt2yII=";
    };
  };
in {
  inherit ja-netfilter;
} // lib.mapAttrs' (name: attrs:
  let package = pluginBase ({ inherit name; } // attrs);
  in {
    name = package.pname;
    value = package;
  }) plugins
