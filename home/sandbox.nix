{ config, pkgs, lib, ... }:
{
  import = [
    "./default.nix"
  ];

  home.username = "root";
  home.homeDirectory = "/root";
}
