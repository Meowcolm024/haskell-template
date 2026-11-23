{
  description = "Minimal Haskell project";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/*";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        hPkgs = pkgs.haskellPackages;
        project = hPkgs.callCabal2nix "project" ./. { };
      in
      {
        packages.project = project;

        apps.default = {
          type = "app";
          program = pkgs.lib.getExe' project "example-exe"; # executable name
        };

        devShells.default = hPkgs.shellFor {
          packages = _: [ project ];

          nativeBuildInputs = [
            pkgs.cabal-install
            pkgs.hpack
            hPkgs.haskell-language-server
            hPkgs.cabal-gild
            hPkgs.ormolu
          ];

          buildInputs = [ ];

          shellHook = ''
            hpack --silent
          '';
        };
      }
    )
    // {
      templates.default = {
        path = ./.;
        description = "Minimal Haskell + Hpack + Nix project";
      };
    };
}
