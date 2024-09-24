{
  description = "lndbm.me";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      systems = [ "x86_64-linux" ];
      eachSystem =
        f:
        let
          forAllSystems = nixpkgs.lib.genAttrs systems;
        in
        forAllSystems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      formatter = eachSystem (
        {
          pkgs,
          system,
        }:
        let
          treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        treefmtEval.config.build.wrapper
      );

      packages = eachSystem (
        { pkgs, system }:
        {
          default = pkgs.writeShellApplication {
            name = "serve";

            runtimeInputs = with pkgs; [ live-server ];

            text = ''
              live-server -p 8080 ./src
            '';
          };
        }
      );

      apps = eachSystem (
        { pkgs, system }:
        {
          default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/serve";
          };
        }
      );
    };
}
