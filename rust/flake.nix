{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    fenix.url = "github:nix-community/fenix";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      naersk,
      fenix,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
        rustToolchain = {
          rustToolchain =
            with fenix.packages.${system};
            combine [
              (default.withComponents [
                # use rust nightly
                "rustc"
                "cargo"
                "rustfmt"
                "clippy"
                "rust-src"
              ])

              targets.wasm32-unknown-unknown.stable.rust-std
              targets.x86_64-pc-windows-gnu.stable.rust-std
            ];
        };
      in
      {
        defaultPackage = naersk-lib.buildPackage ./.;
        devShell =
          with pkgs;
          mkShell {
            buildInputs = [
              rustToolchain
            ];
          };
      }
    );
}
