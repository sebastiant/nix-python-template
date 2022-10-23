{
  description = "Template flake for Python projects";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
    poetry2nix = {
      url = github:nix-community/poetry2nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    {
      overlay = nixpkgs.lib.composeManyExtensions [
        poetry2nix.overlay
        (final: prev: {
          myapp = prev.poetry2nix.mkPoetryApplication {
            projectDir = ./.;
          };
        })
      ];
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };
        myappEnv = pkgs.poetry2nix.mkPoetryEnv { projectDir = ./.; };
      in
      rec {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              myappEnv
            ];
          };
        apps.myapp = pkgs.myapp;
        defaultApp = apps.myapp;
      }));
}
