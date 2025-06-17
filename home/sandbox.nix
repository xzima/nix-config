{ config, pkgs, lib, ... }:
{
  imports = [
    ./default.nix
  ];

  home.username = "root";
  home.homeDirectory = "/root";
  home.sessionVariables = {
    TEST = "hello from home/sandbox";
  };
}
