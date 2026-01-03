{ flake, inputs, hostName, perSystem, config, modulesPath, pkgs, lib, ... }:
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-flatpak.nixosModules.nix-flatpak
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
#    substituters = [ "https://cosmic.cachix.org/" ];
#    trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
  };
  # Disables all users for this host
  home-manager.users = lib.mkForce { };


  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        inherit (final) config;
      };
    })
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = hostName; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  # services.power-profiles-daemon.enable = false; # power profile service
  # services.upower.enable = false; # battery interface
  # services.udisks2.enable = true; # device automount

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
   services.displayManager.gdm.enable = true;
   services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb = {
  #   layout = "us";
  #   variant = "";
  # };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.unstable.pantum-driver ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # services.flatpak = {
  #   enable = true;
  #   uninstallUnmanaged = true;
  #   packages = [
  #     #{ appId = "com.jetbrains.IntelliJ-IDEA-Ultimate"; commit = ""; }
  #   ];
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zx = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "input" "docker" ];

    # packages = with pkgs; [
    #   #  thunderbird
    #   keeweb
    #   firefox
    #   dconf-editor
    #   jetbrains.idea-ultimate
    # ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    pkgs.home-manager
  ];

  #DOCKER
  virtualisation.docker = {
    enable = true;
    daemon.settings.data-root = "/storage/docker";
  };
  systemd.services.dc-tor-proxy = {
    wantedBy = [ "multi-user.target" ];
    partOf = [ "docker.service" ];
    after = [ "docker.service" ];
    environment = {
      STORAGE_PATH = "/home/zx";
      PUID = "1000";
      PGID = "1000";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
      WorkingDirectory = "${../docker-stable/composes/tor-proxy}";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
