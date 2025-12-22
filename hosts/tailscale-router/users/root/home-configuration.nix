{ flake, inputs, perSystem, config, pkgs, lib, ... }:
{

  imports = [
    flake.homeModules.shell
  ];

  home.stateVersion = "25.05";

  home.username = "root";
  home.homeDirectory = "/root";

  custom.shell = {
    fix-hostname = true;
  };
}
