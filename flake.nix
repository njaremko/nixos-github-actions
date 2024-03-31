{
  description = "Another approach to github-runners in nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs: {
    nixosModules = {
      default = ./module.nix;
    };
  };
}
