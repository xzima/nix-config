{ config, pkgs, lib, ... }:
{
  imports = [
    ./default.nix
  ];

  home.username = "root";
  home.homeDirectory = "/root";
}
