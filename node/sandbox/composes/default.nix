{ config, modulesPath, pkgs, lib, ... }:
let
  mkCompose = { projectPath, envs, after ? [ ], ... }: {
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" "docker.socket" ] ++ after;
    environment = envs;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose --project-directory ${projectPath} up -d";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose --project-directory ${projectPath} stop";
    };
  };
in
{
  systemd.services.dc-whoami = mkCompose {
    projectPath = ./whoami;
    envs = {
      TZ = "Europe/Moscow";
      PUID = "0";
      PGID = "0";
    };
  };
  systemd.services.homepage = mkCompose {
    projectPath = ./homepage;
    envs = {
      TZ = "Europe/Moscow";
      PUID = "0";
      PGID = "0";
    };
    after = [ config.systemd.services.dc-whoami.name ];
  };
}
