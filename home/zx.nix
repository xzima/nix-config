{ config, pkgs, lib, ... }:
{
  imports = [
    #    ./modules/shell
  ];

  home = {
    username = "zx";
    homeDirectory = "/home/zx";
    stateVersion = "25.05";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    keeweb
    jetbrains.idea-ultimate
  ];

  programs.firefox.enable = true;

  programs.dankMaterialShell = {
    enable = true;
    niri = {
      enableKeybinds = true; # Automatic keybinding configuration
      enableSpawn = true; # Auto-start DMS with niri
    };
    greeter = {
      enable = true;
      compositor.name = "niri";
    };
    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dankMaterialShell changes
    };

    # Core features
    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableClipboard = true; # Clipboard history manager
    enableVPN = true; # VPN management widget
    enableBrightnessControl = true; # Backlight/brightness controls
    enableColorPicker = true; # Color picker tool
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
    enableSystemSound = true; # System sound effects
  };
}
