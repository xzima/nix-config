{ config, modulesPath, pkgs, lib, ... }:
{
  # Flake specific
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Proxmox specific https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/proxmox-lxc.nix
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./composes
  ];
  environment.variables = {
    TERM = "xterm-256color";
  };
  ###
  time.timeZone = "Europe/Moscow";
  # set zsh as default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  # protect ssh
  services.openssh = {
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      KexAlgorithms = [ "curve25519-sha256@libssh.org" ];
      Ciphers = [ "aes256-gcm@openssh.com" "aes256-ctr" ];
      Macs = [ "hmac-sha2-256-etm@openssh.com" "hmac-sha2-256" ];
    };
  };
  # packages
  environment.systemPackages = [
    pkgs.docker-compose
  ];
  # Docker specific
  virtualisation.docker = {
    enable = true;
    # daemon.settings.data-root = "/share/docker";
    # storageDriver = "zfs";
    autoPrune = {
      enable = true;
      flags = [ "--all" "--force" ];
      dates = "daily";
    };
  };
  users.users.root.extraGroups = [ "docker" ];

  age.secrets = {
    "domain.env".file = ../../secrets/node/sandbox/domain.env.age;
    "token.txt".file = ../../secrets/node/sandbox/token.txt.age;
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
