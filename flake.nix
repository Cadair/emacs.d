{
  description = "Cadair's Emacs Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }: {
      homeManagerModules.cadair-emacs =
        { ... }:
        {
          imports = [ ./nix ];
        };

    };
}
