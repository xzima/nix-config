# https://gist.github.com/mosquito/b23e1c1e5723a7fd9e6568e5cf91180f
{ config, pkgs, lib, ... }:
let
  mkCompose = { projectPath, envs ? { }, envFiles ? [ ], ... }: {
    wantedBy = [ "multi-user.target" ];
    partOf = [ "docker.service" ];
    after = [ "docker.service" "docker.socket" ];
    environment = envs;
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
  systemd.services.dc-whoami = mkCompose {
    projectPath = ./whoami;
    envFiles = [
      ./first.env
      ./second.env
    ];
  };
  systemd.services.dc-homepage = mkCompose {
    projectPath = ./homepage;
    envFiles = [
      ./first.env
      ./second.env
    ];
  };
}
