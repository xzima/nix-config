{ config, modulesPath, pkgs, lib, ... }:
let
  gitea-shell = pkgs.writeShellScriptBin "gitea-shell" ''
    #!/bin/sh
    ${pkgs.docker}/bin/docker exec -i --env SSH_ORIGINAL_COMMAND="''$SSH_ORIGINAL_COMMAND" gitea-container-name sh "''$@"
  '';
in
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
  # executed on configuration
  system.activationScripts = {
    # Gitea Docker SSH Forwarding
    gitea-docker-ssh-forwarding.text = ''
      usermod -s ${gitea-shell}/bin/gitea-shell git
    '';
  };
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
    # Gitea Docker SSH Forwarding
    extraConfig = ''
      Match User git
        AuthorizedKeysCommandUser git
        AuthorizedKeysCommand ${pkgs.docker}/bin/docker exec -i gitea-container-name /usr/local/bin/gitea keys -e git -u %u -t %t -k %k
    '';
  };
  # packages https://search.nixos.org/packages
  environment.systemPackages = [
    pkgs.docker-compose
    pkgs.dig
    pkgs.unzip
    pkgs.ffmpeg
    gitea-shell # Gitea Docker SSH Forwarding
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
  users.users = {
    # Docker specific
    root.extraGroups = [ "docker" ];
    # Gitea Docker SSH Forwarding
    git = {
      group = "git";
      isSystemUser = true;
      extraGroups = [ "docker" ];
    };
  };
  users.groups.git = { };

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
    # photoprism
    "photoprism.mariadb-password.txt" = {
      file = ../../secrets/node/docker-stable/photoprism.mariadb-password.txt.age;
      mode = "444";
    };
    "photoprism.password.txt" = {
      file = ../../secrets/node/docker-stable/photoprism.password.txt.age;
      mode = "444";
    };
    # awg-proxy
    "awg-proxy.awg.conf" = {
      file = ../../secrets/node/docker-stable/awg-proxy.awg.conf.age;
      mode = "444";
    };
    # gitea
    "gitea.postgres-db-name.txt" = {
      file = ../../secrets/node/docker-stable/gitea.postgres-db-name.txt.age;
      mode = "444";
    };
    "gitea.postgres-username.txt" = {
      file = ../../secrets/node/docker-stable/gitea.postgres-username.txt.age;
      mode = "444";
    };
    "gitea.postgres-password.txt" = {
      file = ../../secrets/node/docker-stable/gitea.postgres-password.txt.age;
      mode = "444";
    };
    "gitea.lfs-jwt-secret.txt" = {
      file = ../../secrets/node/docker-stable/gitea.lfs-jwt-secret.txt.age;
      mode = "444";
    };
    "gitea.secret-key.txt" = {
      file = ../../secrets/node/docker-stable/gitea.secret-key.txt.age;
      mode = "444";
    };
    "gitea.jwt-secret.txt" = {
      file = ../../secrets/node/docker-stable/gitea.jwt-secret.txt.age;
      mode = "444";
    };
    "gitea.internal-token.txt" = {
      file = ../../secrets/node/docker-stable/gitea.internal-token.txt.age;
      mode = "444";
    };
  };
}
