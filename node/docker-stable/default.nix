{ config, modulesPath, pkgs, lib, ... }:
{
  system.stateVersion = "25.05";
  # Flake specific
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Proxmox specific https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/proxmox-lxc.nix
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./composes
  ];
  environment.variables = {
    TERM = "xterm-256color"; # fix proxmox terminal colors
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
    pkgs.dig
  ];
  # Docker specific
  virtualisation.docker = {
    enable = true;
    daemon.settings.data-root = "/storage/docker";
    autoPrune = {
      enable = true;
      flags = [ "--all" "--force" ];
      dates = "daily";
    };
  };
  users.users.root.extraGroups = [ "docker" ];

  age.secrets = {
    "base.env".file = ../../secrets/node/docker-stable/base.env.age;
    # traefik
    "myaddr-token".file = ../../secrets/node/docker-stable/myaddr-token.age;
    "traefik.env".file = ../../secrets/node/docker-stable/traefik.env.age;
    "traefik-secret".file = ../../secrets/node/docker-stable/traefik-secret.age;
    # nextcloud
    "nextcloud.postgres-db-name.txt".file = ../../secrets/node/docker-stable/nextcloud.postgres-db-name.txt.age;
    "nextcloud.postgres-username.txt".file = ../../secrets/node/docker-stable/nextcloud.postgres-username.txt.age;
    "nextcloud.postgres-password.txt".file = ../../secrets/node/docker-stable/nextcloud.postgres-password.txt.age;
    "nextcloud.username.txt".file = ../../secrets/node/docker-stable/nextcloud.username.txt.age;
    "nextcloud.password.txt".file = ../../secrets/node/docker-stable/nextcloud.password.txt.age;
    # onlyoffice
    "onlyoffice.env".file = ../../secrets/node/docker-stable/onlyoffice.env.age;
  };
}
