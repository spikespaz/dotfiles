{ fetchgit, }:
let
  repoOwner = "ja-netfilter";
  baseName = "ja-netfilter";

  packageBase = import ./base.nix;
  pluginBase = { name, version, srcHash, depsHash, }:
    packageBase {
      pname = "${baseName}-plugin-${name}";
      src = fetchgit {
        url = "https://gitee.com/${repoOwner}/plugin-${name}.git";
        rev = version;
        sha256 = srcHash;
      };
      # maven outputs the jar name with an extra `v` in the version segment
      targetJar = "${name}-v${version}-jar-with-dependencies.jar";
      renameJar = "share/${baseName}/plugins/${name}.jar";
      inherit version depsHash;
    };
in {
  ja-netfilter = packageBase rec {
    pname = baseName;
    version = "2022.2.0";
    src = fetchgit {
      url = "https://gitee.com/${repoOwner}/ja-netfilter.git";
      rev = version;
      sha256 = "sha256-jlRJ2r9EnbaqG7tGhJduFCchORdraZL3aTBa1btgMIU=";
    };
    depsHash = "sha256-B8kZKC1FilK/wWNzlrQgDVj+T0EhScK2o2lAtFK8FqY=";
    targetJar = "ja-netfilter-jar-with-dependencies.jar";
    renameJar = "share/${baseName}/ja-netfilter.jar";
  };
  plugin-dns = pluginBase {
    name = "dns";
    version = "v1.1.0";
    srcHash = "sha256-JSBGjQY7KmO7pcrATY5Ql9eg+hQUHqy9869uINLz+Fo=";
    depsHash = "sha256-B8kZKC1FilK/wWNzlrQgDVj+T0EhScK2o2lAtFK8FqY=";
  };
  plugin-url = pluginBase {
    name = "url";
    version = "v1.1.0";
    srcHash = "sha256-7YiiPDjQr6vN933svHwz1yK3PdWTsY2SeJsw+PBv+zY=";
    depsHash = "sha256-B8kZKC1FilK/wWNzlrQgDVj+T0EhScK2o2lAtFK8FqY=";
  };
  plugin-hideme = pluginBase {
    name = "hideme";
    version = "v1.1.0";
    srcHash = "sha256-tGAesHIGmdlp2PCTfX5zrikqjD9ZiQ+0tLsJFGiWwPQ=";
    depsHash = "sha256-B8kZKC1FilK/wWNzlrQgDVj+T0EhScK2o2lAtFK8FqY=";
  };
  plugin-dump = pluginBase {
    name = "dump";
    version = "v1.0.1";
    srcHash = "";
    depsHash = "";
  };
  plugin-native = pluginBase {
    name = "native";
    version = "v1.0.0";
    srcHash = "";
    depsHash = "";
  };
  plugin-power = pluginBase {
    name = "power";
    version = "v1.1.0";
    srcHash = "sha256-sTjHvpQYF6soRIDhPspCdLYqLfZwPCjERq1EhIvX9z0=";
    depsHash = "sha256-S5SnS27x+vTwHd8Z6J8dO/wgThQClkgQv1WPJkFiyK8=";
  };
}
