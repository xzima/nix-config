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
    xwayland-satellite-stable
  ];

  # browser
  programs.firefox.enable = true;
  # terminal
  programs.alacritty.enable = true;
  programs.fish = {
    enable = true;
  };
  # index
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.dankMaterialShell = {
    enable = true;
    niri = {
      enableKeybinds = true; # Automatic keybinding configuration
      enableSpawn = true; # Auto-start DMS with niri
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

    default.settings = {
      theme = "dark";
      dynamicTheming = true;
    };
  };
}
