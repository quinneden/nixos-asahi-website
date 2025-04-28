{ stdenvNoCC, gemSet }:
stdenvNoCC.mkDerivation {
  pname = "nixos-asahi-website";
  version = "0.1.0";
  src = ./.;

  buildInputs = [
    gemSet
    gemSet.wrappedRuby
  ];

  buildPhase = ''
    runHook preBuild
    jekyll build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    mv _site $out/srv
    runHook postInstall
  '';
}
