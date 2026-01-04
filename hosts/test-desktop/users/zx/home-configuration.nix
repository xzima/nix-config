{ flake, inputs, perSystem, config, pkgs, lib, ... }:
{

  imports = [
    #flake.homeModules.shell
    inputs.nix-index-database.homeModules.nix-index
    inputs.noctalia.homeModules.default
    inputs.niri.homeModules.niri
    ../../overlay.nix
  ];

  nixpkgs.overlays = [
    inputs.niri.overlays.niri
  ];

  home = {
    username = "zx";
    homeDirectory = "/home/zx";
    stateVersion = "25.05";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    keeweb # password manager
    (
      let
        ideaOverAttr = pkgs.jetbrains.idea.overrideAttrs (old: rec {
          src = builtins.fetchurl {
            url = builtins.replaceStrings [ "download.jetbrains.com" ] [ "download-cdn.jetbrains.com" ] (
              builtins.head old.src.urls
            );
            sha256 = old.src.outputHash;
          };
        });
        ideaOver = ideaOverAttr.override {
          forceWayland = true;
        };
      in
      ideaOver
      #      pkgs.buildFHSEnv {
      #        name = "idea";
      #        targetPkgs = pkgs: [
      #          ideaOver
      #        ];
      #        multiPkgs = pkgs: pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs pkgs;
      #        runScript = "idea $*";
      #        extraInstallCommands = ''
      #          ln -s "${ideaOver}/share" $out
      #        '';
      #      }
    )
    xwayland-satellite-stable # fix idea
    colordiff
    wev
    seahorse # keyring gui
    dconf-editor # dconf viewer
    nerd-fonts.fira-code
    podman-compose
    junction
    zip
    unzip
    git
  ];

  home.file = {
    ".dotfiles/micro" = {
      source = ../../../../modules/home/shell/dotfiles/micro;
      recursive = true;
    };
  };

  # browser
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0; # 0 is Default
        name = "default";
      };
      "z7r.zima" = {
        id = 1;
        name = "z7r.zima";
      };
    };
  };
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/firefox/wrapper.nix
  xdg.desktopEntries = {
    "firefox-z7r.zima" = {
      name = "[z7r.zima]Firefox";
      genericName = "Web Browser (z7r.zima)";
      icon = "firefox";
      exec = "firefox -P z7r.zima --class=firefox-z7r.zima %U";
      categories = [ "Network" "WebBrowser" ];
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/vnd.mozilla.xul+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      startupNotify = true;
      terminal = false;
      settings = {
        StartupWMClass = "firefox-z7r.zima";
      };
    };
  };
  # containers
  services.podman = {
    enable = true;
    networks.proxy = { };
  };
  systemd.user.services.pc-tor-proxy = {
    Unit = {
      After = [ "podman-proxy-network.service" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Environment = [
        "STORAGE_PATH=${config.home.homeDirectory}"
        "PUID=1000"
        "PGID=1000"
      ];

      Type = "oneshot";
      RemainAfterExit = "true";
      WorkingDirectory = "${../../../docker-stable/composes/tor-proxy}";
      ExecStart = "${pkgs.podman-compose}/bin/podman-compose --pod-args '--userns keep-id' up -d --remove-orphans";
      ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };
  # terminal
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    settings = {
      shell = "fish";
    };
    keybindings = {
      "ctrl+v" = "paste_from_clipboard";
      "ctrl+shift+v" = "no_op";
    };
    extraConfig = ''
      include themes/noctalia.conf
    '';
  };
  programs.jq.enable = true;
  programs.fish = {
    enable = true;
  };
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    plugins = {
      mount = pkgs.yaziPlugins.mount;
    };
    keymap = {
      manager.prepend_keymap = [
        {
          on = "M";
          run = "plugin mount";
          desc = "Enter Mount Manager";
        }
      ];
    };
    theme = {
      flavor = {
        dark = "noctalia";
        light = "noctalia";
      };
    };
  };
  programs.micro = {
    enable = true;
  };

  # TODO:
  # [x] hx --tutor g441g
  # [ ] https://tomgroenwoldt.github.io/helix-shortcut-quiz/
  # [ ] https://nik-rev.github.io/helix-golf/
  programs.helix = {
    enable = true;
    extraPackages = with pkgs; [ nixd yaml-language-server docker-compose-language-service ];
    settings = {
      theme = "autumn_night_transparent";
      editor = {
        shell = [ "fish" "-c" ];
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
    };
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
        }
      ];
      language-server = {
        nixd = {
          command = "nixd";
          args = [ "--semantic-tokens=true" ];
          config.nixd =
            let
              myFlake = ''(builtins.getFlake "${config.home.homeDirectory}/nix-config"'';
              nixosOpts = "${myFlake}.nixosConfigurations.test-desktop.options";
            in
            {
              nixpkgs.expr = "import ${myFlake}.inputs.nixpkgs { }";
              formatting.command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
              options = {
                nixos.expr = nixosOpts;
                home-manager.expr = "${nixosOpts}.home-manager.users.type.getSubOptions [ ]";
              };
            };
        };
      };
    };
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };

  # index
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
  };

  programs.niri = {
    enable = true;
    settings = {
      input.keyboard.xkb = {
        layout = "us,ru";
        options = "grp:caps_toggle";
      };
      environment = {
        EDITOR = "micro";
        MICRO_CONFIG_HOME = "${config.home.homeDirectory}/.dotfiles/micro";
      };
      binds = with config.lib.niri.actions; {
        # Keys consist of modifiers separated by + signs, followed by an XKB key name
        # in the end. To find an XKB name for a particular key, you may use a program
        # like wev.
        #
        # "Mod" is a special modifier equal to Super when running on a TTY, and to Alt
        # when running as a winit window.
        #
        # Most actions that you can bind here can also be invoked programmatically with
        # `niri msg action do-something`.

        # shows a list of important hotkeys.
        "Mod+F1".action = show-hotkey-overlay;

        # Suggested binds for running programs: terminal, app launcher, screen locker.
        "Ctrl+Alt+T" = {
          action = spawn "kitty";
          hotkey-overlay.title = "Spawn terminal (Kitty)";
        };
        "Mod+E" = {
          action = spawn "kitty" "-e" "yazi";
          hotkey-overlay.title = "Spawn File Manager";
        };

        "Ctrl+Shift+V" = {
          action = spawn "noctalia-shell" "ipc" "call" "launcher" "clipboard";
          hotkey-overlay.title = "Toggle Clipboard Manager";
        };
        "Ctrl+Escape" = {
          action = spawn "noctalia-shell" "ipc" "call" "launcher" "toggle";
          hotkey-overlay.title = "Toggle Application Launcher";
        };
        "Ctrl+Alt+Delete" = {
          action = spawn "noctalia-shell" "ipc" "call" "sessionMenu" "toggle";
          hotkey-overlay.title = "Toggle Power Menu";
        };
        "Super+Alt+L" = {
          action = spawn "noctalia-shell" "ipc" "call" "lockScreen" "lock";
          hotkey-overlay.title = "Lock Screen";
        };
        "Mod+Comma" = {
          action = spawn "noctalia-shell" "ipc" "call" "settings" "toggle";
          hotkey-overlay.title = "Toggle Settings";
        };

        # You can also use a shell. Do this if you need pipes, multiple commands, etc.
        # Note: the entire command goes as a single argument in the end.
        # Mod+T { spawn "bash" "-c" "notify-send hello && exec alacritty"; }

        /* SEE https://github.com/AvengeMedia/DankMaterialShell/blob/master/distro/nix/niri.nix
        # Example volume keys mappings for PipeWire & WirePlumber.
        # The allow-when-locked=true property makes them work even when the session is locked.
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" ];
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ];
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
        };
        */

        "Alt+F4" = {
          action = close-window;
          repeat = false;
        };

        "Mod+Left".action = focus-column-left;
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;
        "Mod+Right".action = focus-column-right;
        "Mod+H".action = focus-column-left;
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;
        "Mod+L".action = focus-column-right;

        "Mod+Ctrl+Left".action = move-column-left;
        "Mod+Ctrl+Down".action = move-window-down;
        "Mod+Ctrl+Up".action = move-window-up;
        "Mod+Ctrl+Right".action = move-column-right;
        "Mod+Ctrl+H".action = move-column-left;
        "Mod+Ctrl+J".action = move-window-down;
        "Mod+Ctrl+K".action = move-window-up;
        "Mod+Ctrl+L".action = move-column-right;

        # Alternative commands that move across workspaces when reaching
        # the first or last window in a column.
        # Mod+J     { focus-window-or-workspace-down; }
        # Mod+K     { focus-window-or-workspace-up; }
        # Mod+Ctrl+J     { move-window-down-or-to-workspace-down; }
        # Mod+Ctrl+K     { move-window-up-or-to-workspace-up; }

        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;
        "Mod+Ctrl+Home".action = move-column-to-first;
        "Mod+Ctrl+End".action = move-column-to-last;

        "Mod+Shift+Left".action = focus-monitor-left;
        "Mod+Shift+Down".action = focus-monitor-down;
        "Mod+Shift+Up".action = focus-monitor-up;
        "Mod+Shift+Right".action = focus-monitor-right;
        "Mod+Shift+H".action = focus-monitor-left;
        "Mod+Shift+J".action = focus-monitor-down;
        "Mod+Shift+K".action = focus-monitor-up;
        "Mod+Shift+L".action = focus-monitor-right;

        "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
        "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

        # Alternatively, there are commands to move just a single window:
        # Mod+Shift+Ctrl+Left  { move-window-to-monitor-left; }
        # ...

        # And you can also move a whole workspace to another monitor:
        # Mod+Shift+Ctrl+Left  { move-workspace-to-monitor-left; }
        # ...

        "Mod+Page_Down".action = focus-workspace-down;
        "Mod+Page_Up".action = focus-workspace-up;
        "Mod+U".action = focus-workspace-down;
        "Mod+I".action = focus-workspace-up;

        "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
        "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
        "Mod+Ctrl+U".action = move-column-to-workspace-down;
        "Mod+Ctrl+I".action = move-column-to-workspace-up;

        # Alternatively, there are commands to move just a single window:
        # Mod+Ctrl+Page_Down { move-window-to-workspace-down; }
        # ...

        "Mod+Shift+Page_Down".action = move-workspace-down;
        "Mod+Shift+Page_Up".action = move-workspace-up;
        "Mod+Shift+U".action = move-workspace-down;
        "Mod+Shift+I".action = move-workspace-up;

        # You can bind mouse wheel scroll ticks using the following syntax.
        # These binds will change direction based on the natural-scroll setting.
        #
        # To avoid scrolling through workspaces really fast, you can use
        # the cooldown-ms property. The bind will be rate-limited to this value.
        # You can set a cooldown on any bind, but it's most useful for the wheel.
        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action = focus-workspace-down;
        };
        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action = focus-workspace-up;
        };
        "Mod+Ctrl+WheelScrollDown" = {
          cooldown-ms = 150;
          action = move-column-to-workspace-down;
        };
        "Mod+Ctrl+WheelScrollUp" = {
          cooldown-ms = 150;
          action = move-column-to-workspace-up;
        };

        "Mod+WheelScrollRight".action = focus-column-right;
        "Mod+WheelScrollLeft".action = focus-column-left;
        "Mod+Ctrl+WheelScrollRight".action = move-column-right;
        "Mod+Ctrl+WheelScrollLeft".action = move-column-left;

        # Usually scrolling up and down with Shift in applications results in
        # horizontal scrolling; these binds replicate that.
        "Mod+Shift+WheelScrollDown".action = focus-column-right;
        "Mod+Shift+WheelScrollUp".action = focus-column-left;
        "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
        "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-left;

        # Similarly, you can bind touchpad scroll "ticks".
        # Touchpad scrolling is continuous, so for these binds it is split into
        # discrete intervals.
        # These binds are also affected by touchpad's natural-scroll, so these
        # example binds are "inverted", since we have natural-scroll enabled for
        # touchpads by default.
        # Mod+TouchpadScrollDown { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02+"; }
        # Mod+TouchpadScrollUp   { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02-"; }

        # You can refer to workspaces by index. However, keep in mind that
        # niri is a dynamic workspace system, so these commands are kind of
        # "best effort". Trying to refer to a workspace index bigger than
        # the current workspace count will instead refer to the bottommost
        # (empty) workspace.
        #
        # For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
        # will all refer to the 3rd workspace.
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+Ctrl+1".action.move-column-to-workspace = 1;
        "Mod+Ctrl+2".action.move-column-to-workspace = 2;
        "Mod+Ctrl+3".action.move-column-to-workspace = 3;
        "Mod+Ctrl+4".action.move-column-to-workspace = 4;
        "Mod+Ctrl+5".action.move-column-to-workspace = 5;
        "Mod+Ctrl+6".action.move-column-to-workspace = 6;
        "Mod+Ctrl+7".action.move-column-to-workspace = 7;
        "Mod+Ctrl+8".action.move-column-to-workspace = 8;
        "Mod+Ctrl+9".action.move-column-to-workspace = 9;

        # Alternatively, there are commands to move just a single window:
        # Mod+Ctrl+1 { move-window-to-workspace 1; }

        # Switches focus between the current and the previous workspace.
        # Mod+Tab { focus-workspace-previous; }

        # SEE https://github.com/AvengeMedia/DankMaterialShell/blob/master/distro/nix/niri.nix
        "Mod+Alt+Comma".action = consume-window-into-column;
        "Mod+Alt+Period".action = expel-window-from-column;

        # There are also commands that consume or expel a single window to the side.
        # Mod+BracketLeft  { consume-or-expel-window-left; }
        # Mod+BracketRight { consume-or-expel-window-right; }

        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = reset-window-height;
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+C".action = center-column;

        # Finer width adjustments.
        # This command can also:
        # * set width in pixels: "1000"
        # * adjust width in pixels: "-5" or "+5"
        # * set width as a percentage of screen width: "25%"
        # * adjust width as a percentage of screen width: "-10%" or "+10%"
        # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
        # set-column-width "100" will make the column occupy 200 physical screen pixels.
        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";

        # Finer height adjustments when in column with other windows.
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        # SEE input.keyboard.xkb.options
        # Actions to switch layouts.
        # Note: if you uncomment these, make sure you do NOT have
        # a matching layout switch hotkey configured in xkb options above.
        # Having both at once on the same hotkey will break the switching,
        # since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
        # Mod+Space       { switch-layout "next"; }
        # Mod+Shift+Space { switch-layout "prev"; }

        "Print".action.screenshot = { };
        "Ctrl+Print".action.screenshot-screen = { };
        "Alt+Print".action.screenshot-window = { };

        # The quit action will show a confirmation dialog to avoid accidental exits.
        "Mod+Shift+E".action = quit;

        # Powers off the monitors. To turn them back on, do any input like
        # moving the mouse or pressing any other key.
        "Mod+Shift+P".action = power-off-monitors;
      };
    };
  };
}
