{ config, modulesPath, pkgs, lib, ... }:
{
  system.stateVersion = "25.05";
  # Flake specific
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Proxmox specific https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/proxmox-lxc.nix
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
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

  age.secrets = {
    auth-file.file = ../../secrets/node/tailscale-router/auth-key.age;
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.auth-file.path;
    useRoutingFeatures = "server";
    extraSetFlags = [ "--advertise-routes=192.168.0.2/32,192.168.0.96/27" ]; # 192.168.0.2,192.168.0.97-126
  };
}
