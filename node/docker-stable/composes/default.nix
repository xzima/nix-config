# https://gist.github.com/mosquito/b23e1c1e5723a7fd9e6568e5cf91180f
# https://nixos.wiki/wiki/Systemd/Timers
# age.secretsDir https://github.com/ryantm/agenix
{ config, pkgs, lib, ... }:
let
  mkCompose = { projectPath, envs ? { }, envFiles ? [ ], after ? [ ], ... }: {
    wantedBy = [ "multi-user.target" ];
    partOf = [ "docker.service" ];
    after = [ "docker.service" ] ++ after;
    environment = envs // { SECRET_PATH = config.age.secretsDir; };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
      WorkingDirectory = projectPath;
      EnvironmentFile = envFiles;
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
    };
  };
in
{
  #  systemd.services.dc-whoami = mkCompose {
  #    projectPath = ./whoami;
  #    envFiles = [
  #      ./first.env
  #      config.age.secrets."domain.env".path
  #    ];
  #  };
  #  systemd.services.dc-homepage = mkCompose {
  #    projectPath = ./homepage;
  #    envFiles = [
  #      ./first.env
  #      config.age.secrets."domain.env".path
  #    ];
  #  };
}
