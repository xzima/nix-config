# https://gist.github.com/mosquito/b23e1c1e5723a7fd9e6568e5cf91180f
# https://nixos.wiki/wiki/Systemd/Timers
# age.secretsDir https://github.com/ryantm/agenix
{ config, pkgs, lib, ... }:
let
  mkCompose = { projectPath, envs ? { }, envFiles ? [ ], after ? [ ], isWait ? false, ... }: {
    wantedBy = [ "multi-user.target" ];
    partOf = [ "docker.service" ];
    after = [ "docker.service" ] ++ after;
    environment = envs // { SECRET_PATH = config.age.secretsDir; STORAGE_PATH = "/storage/services"; };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
      WorkingDirectory = projectPath;
      EnvironmentFile = envFiles ++ [ config.age.secrets."base.env".path ];
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans ${lib.strings.optionalString isWait "--wait"}";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };
in
{

  systemd.services.dc-traefik = mkCompose {
    isWait = true;
    projectPath = ./traefik;
    envFiles = [
      config.age.secrets."traefik.env".path
    ];
  };

  systemd.services.dc-homepage = mkCompose {
    after = [ config.systemd.services.dc-traefik.name ];
    projectPath = ./homepage;
  };

  systemd.services.dc-whoami = mkCompose {
    after = [ config.systemd.services.dc-traefik.name ];
    projectPath = ./whoami;
  };

  systemd.services.dc-nextcloud = mkCompose {
    after = [ config.systemd.services.dc-traefik.name ];
    projectPath = ./nextcloud;
  };

  systemd.services.dc-onlyoffice = mkCompose {
    after = [ config.systemd.services.dc-traefik.name ];
    projectPath = ./onlyoffice;
    envFiles = [
      config.age.secrets."onlyoffice.env".path
    ];
  };

  systemd.services.dc-trilium = mkCompose {
    after = [ config.systemd.services.dc-traefik.name ];
    projectPath = ./trilium;
  };

  systemd.services.dc-photoprism = mkCompose {
    after = [ config.systemd.services.dc-traefik.name ];
    projectPath = ./photoprism;
  };
}
