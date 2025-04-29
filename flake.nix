{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs =
    { nixpkgs, ... }:
    let
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ] (
          system:
          f rec {
            pkgs = import nixpkgs { inherit system; };
            gemSet = pkgs.bundlerEnv {
              name = "nixos-asahi-website";
              gemdir = ./.;
            };
          }
        );
    in
    {
      devShells = forEachSystem (
        { gemSet, pkgs }:
        {
          default = pkgs.mkShell {
            name = "nixos-asahi-website";
            packages = with pkgs; [
              bundix
              bundler
              gemSet
              gemSet.wrappedRuby
            ];
          };
        }
      );

      packages = forEachSystem (
        { gemSet, pkgs }:
        rec {
          default = nixos-asahi-website;
          nixos-asahi-website = pkgs.callPackage ./package.nix { inherit gemSet; };
        }
      );

      formatter = forEachSystem ({ pkgs, ... }: pkgs.nixfmt-rfc-style);
    };
}
