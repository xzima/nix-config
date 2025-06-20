{ config, pkgs, lib, ... }:
{
  home.stateVersion = "25.05";
  imports = [
    ./myZsh.nix
  ];

  home.username = "root";
  home.homeDirectory = "/root";

  programs.myZsh = {
    fix-hostname = true;
    antigenBundles = [ "docker" "docker-compose" ];
  };
}
