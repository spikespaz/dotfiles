{ fetchFromGitHub, maven }:
let version = "2.0.1";
in maven.buildMavenPackage {
  pname = "hotswap-agent";
  inherit version;
  src = fetchFromGitHub {
    owner = "HotswapProjects";
    repo = "HotswapAgent";
    rev = "RELEASE-${version}";
    hash = "sha256-wWheRsUwTv7GmWM3/Xl3YEmiFRdMhHGfZl0yJ7YPYOw=";
  };
  mvnHash = "sha256-CxhoHol+aVXdAlKRyzeEnPDub2aV8TP8o2uq4vvS6Ug=";
  doCheck = false;
  installPhase = ''
    runHook preInstall
    install -Dm644 hotswap-agent/target/hotswap-agent-${version}.jar $out/share/java/hotswap-agent.jar
    runHook postInstall
  '';
}
