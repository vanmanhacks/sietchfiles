{
  description = "Example NixOS deployment via NixOS-anywhere";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # disko.url = "github:nix-community/disko";
    # disko.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
    impermanence.url = "github:nix-community/impermanence";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codebase-memory-mcp.url = "github:DeusData/codebase-memory-mcp";
    # honcho-ai-src = {
    # url = "github:plastic-labs/honcho";
    # flake = false;
    # };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, llm-agents, impermanence, lanzaboote, codebase-memory-mcp, ... }:
    let
      flakeSettings = {
        username = "CHANGE_ME_USERNAME";
        hostname = "CHANGE_ME_HOSTNAME";
        system = "x86_64-linux";
        email = "CHANGE_ME_EMAIL";
      };
      unstablePkgs = import nixpkgs-unstable {
        system = flakeSettings.system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
          "caido-cli"
          "payloadsallthethings"
          "mat2"
          "signal-cli"
        ];
      };
    in
    {
      nixosConfigurations.${flakeSettings.hostname} = nixpkgs.lib.nixosSystem {
        system = flakeSettings.system;
        specialArgs = {
          inherit inputs flakeSettings;
          unstable = unstablePkgs;
        };
        modules = [
          ./profile/configuration.nix
          impermanence.nixosModules.impermanence
          lanzaboote.nixosModules.lanzaboote
          ({ unstable, modulesPath, ... }: {
            nixpkgs.overlays = [
              (final: prev: {
                caido-unstable = unstable.caido-cli;
                payloadsallthethings-unstable = unstable.payloadsallthethings;
                mat2-unstable = unstable.mat2;
                signal-cli-unstable = unstable.signal-cli;
              })
            ];
          })
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "hm-backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${flakeSettings.username} = import ./profile/home.nix;
            home-manager.extraSpecialArgs = { inherit flakeSettings; };
          }
        ];
      };
    };
}
