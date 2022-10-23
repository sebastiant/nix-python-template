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
      overlay = final: prev: {
        myapp = final.poetry2nix.mkPoetryApplication {
          projectDir = ./.;
          python = final.python39;
        };
        myappEnv = final.poetry2nix.mkPoetryEnv {
          editablePackageSources = { myapp = ./.; };
          projectDir = ./.;
          python = final.python39;
        };
        myappTests = final.writeScriptBin "tests" ''
          watchexec -e py "pytest"
        '';
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };
      in rec {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ myappEnv myappTests watchexec ];
        };
        apps.myapp = pkgs.myapp;
        defaultApp = apps.myapp;
        defaultPackage = pkgs.myapp;
      }));
}
