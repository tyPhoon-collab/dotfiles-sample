{
  description = "Sample consumer flake for core";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:nix-community/nixvim/main";

    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };

    core = {
      url = "github:tyPhoon-collab/core";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      darwin,
      core,
      ...
    }@inputs:
    let
      coreHomeManager = import (core + /lib/home-manager.nix);

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkExtraArgs =
        {
          username,
          homeDirectory,
          coreConfig,
        }:
        {
          inherit
            username
            homeDirectory
            core
            coreConfig
            ;
          inherit (inputs) hunk nixvim;
          yaziPlugins = inputs.yazi-plugins;
        };

      baseCoreConfig = {
        identity = {
          name = "Sample User";
          email = "sample@example.com";
        };

        system = {
          devLevel = 1;
        };
      };

      desktopCoreConfig = nixpkgs.lib.recursiveUpdate baseCoreConfig {
        system = {
          desktop = true;
          fonts = true;
          devLevel = 2;
        };
      };

      profiles = {
        linux = {
          name = "sample-linux";
          system = "x86_64-linux";
          username = "sample";
          homeDirectory = "/home/sample";
          coreConfig = baseCoreConfig;
        };

        darwin = {
          name = "sample-darwin";
          system = "aarch64-darwin";
          username = "sample";
          homeDirectory = "/Users/sample";
          coreConfig = desktopCoreConfig;
        };
      };
    in
    {
      homeConfigurations.${profiles.linux.name} =
        let
          inherit (profiles.linux)
            username
            homeDirectory
            coreConfig
            ;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs profiles.linux.system;
          extraSpecialArgs = mkExtraArgs {
            inherit username homeDirectory coreConfig;
          };
          modules = [ ./home.nix ];
        };

      darwinConfigurations.${profiles.darwin.name} =
        let
          inherit (profiles.darwin)
            username
            homeDirectory
            coreConfig
            ;
        in
        darwin.lib.darwinSystem {
          system = profiles.darwin.system;
          pkgs = mkPkgs profiles.darwin.system;
          specialArgs = {
            inherit
              inputs
              username
              homeDirectory
              coreConfig
              ;
          };
          modules = [
            ./darwin.nix
            home-manager.darwinModules.home-manager
            {
              home-manager = coreHomeManager.default // {
                users.${username} = import ./home.nix;
                extraSpecialArgs = mkExtraArgs {
                  inherit username homeDirectory coreConfig;
                };
              };
            }
          ];
        };
    };
}
