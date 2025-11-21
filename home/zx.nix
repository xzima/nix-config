{ config, pkgs, lib, ... }:
{
  imports = [
    #    ./modules/shell
  ];

  home = {
    username = "zx";
    homeDirectory = "/home/zx";
    stateVersion = "25.05";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    keeweb
    jetbrains.idea-ultimate
  ];

  programs.firefox.enable = true;

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
  };

  programs.niri = {
    enable = true;
  };
}
