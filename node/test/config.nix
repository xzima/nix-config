{ config, modulesPath, pkgs, lib, ... }:
{
  # Proxmox specific https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/proxmox-lxc.nix
  imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];

  #security.pam.services.sshd.allowNullPassword = true;

  system.stateVersion = "24.11";
}
