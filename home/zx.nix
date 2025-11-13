{ config, pkgs, lib, ... }:
{
  home.stateVersion = "25.05";
  imports = [
    #    ./modules/shell
  ];

  home = {
    username = "zx";
    homeDirectory = "/home/zx";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    keeweb
    dconf-editor
    jetbrains.idea-ultimate
  ];

  programs.firefox.enable = true;
}
