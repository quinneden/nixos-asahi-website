{
  description = "Personal website for Chris Portela";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    risotto = {
      url = "github:joeroe/risotto?ref=v0.4.0";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      forEachSystem =
        f:
        lib.genAttrs [ "aarch64-darwin" "aarch64-linux" ] (
          system: f { pkgs = import nixpkgs { inherit system; }; }
        );
    in
    {
      packages = forEachSystem (
        { pkgs }:
        rec {
          default = qedenDotDev;
          qedenDotDev = pkgs.stdenv.mkDerivation {
            name = "qeden-dot-dev";
            src = builtins.filterSource (
              path: type: !(type == "directory" && (baseNameOf path == "themes" || baseNameOf path == "public"))
            ) ./.;

            nativeBuildInputs = with pkgs; [
              hugo
              prettier
            ];

            buildPhase = ''
              mkdir -p themes
              ln -s ${inputs.risotto} themes/risotto
              hugo --gc --minify
              prettier -w public '!**/*.{js,css}'
            '';

            installPhase = ''
              install -Dt $out public
            '';
          };
        }
      );

      devShells = forEachSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            name = "qeden.dev";
            buildInputs = [ pkgs.hugo ];
          };
        }
      );
    };
}
