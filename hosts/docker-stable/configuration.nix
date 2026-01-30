{ flake, inputs, hostName, perSystem, config, modulesPath, pkgs, lib, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    # Proxmox specific https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/proxmox-lxc.nix
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./composes
  ];

  system.stateVersion = "25.11";
  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
    # ''$ - escape $ in nix file
    # \''$ - escape $ in bash script in nix file
    gitea-docker-ssh-forwarding.text = ''
      GITEA_SHELL_PATH="/usr/bin/gitea-shell"

      ${pkgs.coreutils-full}/bin/rm -f ''$GITEA_SHELL_PATH

      ${pkgs.coreutils-full}/bin/cat << EOF > "''$GITEA_SHELL_PATH"
      #!/bin/sh
      ${pkgs.docker}/bin/docker exec -i --env SSH_ORIGINAL_COMMAND="\''$SSH_ORIGINAL_COMMAND" gitea-container-name /bin/sh "\''$@"
      EOF

      ${pkgs.coreutils-full}/bin/chmod 755 ''$GITEA_SHELL_PATH
      ${pkgs.shadow}/bin/usermod -s ''$GITEA_SHELL_PATH git
    '';
  };
  # protect ssh
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      KexAlgorithms = [ "curve25519-sha256@libssh.org" ];
      Ciphers = [ "aes256-gcm@openssh.com" "aes256-ctr" ];
      Macs = [ "hmac-sha2-256-etm@openssh.com" "hmac-sha2-256" ];
    };
    # Gitea Docker SSH Forwarding
    # authorizedKeysCommand cannot reside in the /nix/store/...
    # see https://github.com/NixOS/nixpkgs/issues/94653#issuecomment-673295418
    extraConfig = ''
      Match User git
        AuthorizedKeysCommandUser git
        AuthorizedKeysCommand /usr/bin/gitea-shell -c "/usr/local/bin/gitea keys -e git -u %u -t %t -k %k"
    '';
  };
  # packages https://search.nixos.org/packages
  environment.systemPackages = [
    pkgs.docker-compose
    pkgs.dig
    pkgs.unzip
    pkgs.ffmpeg
    pkgs.docker-buildx
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
    "base.env".file = ./secrets/base.env.age;
    # traefik
    "myaddr-token".file = ./secrets/myaddr-token.age;
    "traefik.env".file = ./secrets/traefik.env.age;
    "traefik-secret".file = ./secrets/traefik-secret.age;
    # nextcloud
    "nextcloud.postgres-db-name.txt".file = ./secrets/nextcloud.postgres-db-name.txt.age;
    "nextcloud.postgres-username.txt".file = ./secrets/nextcloud.postgres-username.txt.age;
    "nextcloud.postgres-password.txt".file = ./secrets/nextcloud.postgres-password.txt.age;
    "nextcloud.username.txt".file = ./secrets/nextcloud.username.txt.age;
    "nextcloud.password.txt".file = ./secrets/nextcloud.password.txt.age;
    # onlyoffice
    "onlyoffice.env".file = ./secrets/onlyoffice.env.age;
    # photoprism
    "photoprism.mariadb-password.txt" = {
      file = ./secrets/photoprism.mariadb-password.txt.age;
      mode = "444";
    };
    "photoprism.password.txt" = {
      file = ./secrets/photoprism.password.txt.age;
      mode = "444";
    };
    # gitea
    "gitea.postgres-db-name.txt" = {
      file = ./secrets/gitea.postgres-db-name.txt.age;
      mode = "444";
    };
    "gitea.postgres-username.txt" = {
      file = ./secrets/gitea.postgres-username.txt.age;
      mode = "444";
    };
    "gitea.postgres-password.txt" = {
      file = ./secrets/gitea.postgres-password.txt.age;
      mode = "444";
    };
    "gitea.lfs-jwt-secret.txt" = {
      file = ./secrets/gitea.lfs-jwt-secret.txt.age;
      mode = "444";
    };
    "gitea.secret-key.txt" = {
      file = ./secrets/gitea.secret-key.txt.age;
      mode = "444";
    };
    "gitea.jwt-secret.txt" = {
      file = ./secrets/gitea.jwt-secret.txt.age;
      mode = "444";
    };
    "gitea.internal-token.txt" = {
      file = ./secrets/gitea.internal-token.txt.age;
      mode = "444";
    };
    # jellyfin
    "jellyfin.jellystat-postgres-db-name.txt".file = ./secrets/jellyfin.jellystat-postgres-db-name.txt.age;
    "jellyfin.jellystat-postgres-username.txt".file = ./secrets/jellyfin.jellystat-postgres-username.txt.age;
    "jellyfin.jellystat-postgres-password.txt".file = ./secrets/jellyfin.jellystat-postgres-password.txt.age;
    "jellyfin.jellystat-jwt-secret.txt".file = ./secrets/jellyfin.jellystat-jwt-secret.txt.age;
    # wallabag
    "wallabag.env".file = ./secrets/wallabag.env.age;
  };
}
