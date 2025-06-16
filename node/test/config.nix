{ config, modulesPath, pkgs, lib, ... }:
{
  # Proxmox specific https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/proxmox-lxc.nix
  imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users = {
    defaultUserShell = pkgs.zsh;
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  system.stateVersion = "24.11"; # Please read the comment before changing.
}
