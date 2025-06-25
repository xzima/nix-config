{ config, pkgs, lib, ... }:
{
  home.stateVersion = "25.05";
  imports = [
    ./modules/shell
  ];

  home.username = "root";
  home.homeDirectory = "/root";

  custom.shell = {
    fix-hostname = true;
  };
}
