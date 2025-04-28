{
  description = "Static website for nixos-asahi-package built with Hugo and Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nightfall = {
      url = "github:LordMathis/hugo-theme-nightfall";
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
          default = nixos-asahi-website;
          nixos-asahi-website = pkgs.stdenv.mkDerivation {
            name = "nixos-asahi-website";
            version = "0.1.0";
            src = builtins.filterSource (
              path: type: !(type == "directory" && (baseNameOf path == "themes" || baseNameOf path == "public"))
            ) ./.;

            nativeBuildInputs = with pkgs; [
              dart-sass
              hugo
            ];

            buildPhase = ''
              mkdir -p themes
              ln -s ${inputs.nightfall} themes/nightfall
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
            name = "nixos-asahi-website";
            buildInputs = with pkgs; [
              dart-sass
              hugo
            ];
          };
        }
      );
    };
}
