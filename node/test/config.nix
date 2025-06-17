{ config, modulesPath, pkgs, lib, ... }:
{
  # Proxmox specific https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/proxmox-lxc.nix
  imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];
  boot.isContainer = true;
  proxmoxLXC = {
    privileged = true;
    manageHostName = true;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = [
    pkgs.home-manager
  ];
  environment.variables = {
    HOST11 = "$(cat /etc/hostname)";
    HOST = "$(cat /etc/hostname)";
  };
  environment.sessionVariables = {
    HOST12 = "$(cat /etc/hostname)";
  };

  # I had to suppress these units, since they do not work inside LXC
  systemd.suppressedSystemUnits = [
    "dev-mqueue.mount"
    "sys-kernel-debug.mount"
    "sys-fs-fuse-connections.mount"
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  system.stateVersion = "24.11"; # Please read the comment before changing.
}
