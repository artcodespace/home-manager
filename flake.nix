{
  description = "Home Manager configuration of alunturner";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles.url = "github:alunturner/.dotfiles?ref=flake";
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: {
    homeConfigurations.mac = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [./home.nix];
      # Pass all inputs through to modules
      extraSpecialArgs = {inherit inputs;};
    };

    homeConfigurations.linux = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [./home.nix];
      # Pass all inputs through to modules
      extraSpecialArgs = {inherit inputs;};
    };
  };
}
