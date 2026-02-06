{
  flake,
  inputs,
  perSystem,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    #flake.homeModules.shell
    inputs.nix-index-database.homeModules.nix-index
    inputs.noctalia.homeModules.default
    inputs.niri.homeModules.niri
    inputs.stylix.homeModules.stylix
    inputs.niri.homeModules.stylix
    inputs.matugen.nixosModules.default
    inputs.zed-extensions.homeManagerModules.default
    ./theme.nix
  ];

  home = {
    username = "zx";
    homeDirectory = "/home/zx";
    stateVersion = "25.05";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    keeweb # password manager
    jetbrains.idea-fix
    colordiff
    wev
    seahorse # keyring gui
    dconf-editor # dconf viewer
    nerd-fonts.fira-code
    podman-compose
    zip
    unzip
    git
    wl-clipboard
    systemctl-tui
    lazygit
    nix-tree # Interactively browse a Nix store paths dependencies
    # dbus tools
    ashpd-demo # test xdg-portals
    bustle # exploration tool
    (writeShellScriptBin "take-screen" ''
      output=$(${niri-stable}/bin/niri msg --json focused-output | ${jq}/bin/jq -r .name)
      ${grim}/bin/grim -o "''${output}" - | ${satty}/bin/satty --filename -
    '')
  ];

  home.file = {
    ".dotfiles/micro" = {
      source = ../../../../modules/home/shell/dotfiles/micro;
      recursive = true;
    };
  };

  # https://github.com/flameshot-org/flameshot/issues/3605
  # https://github.com/YaLTeR/niri/discussions/1737
  services.flameshot = {
    enable = true;
    # https://github.com/flameshot-org/flameshot/blob/master/flameshot.example.ini
    settings = {
      General = {
        useGrimAdapter = true;
        showDesktopNotification = false;
        showStartupLaunchMessage = false;
      };
    };
  };
  # https://github.com/flameshot-org/flameshot/issues/3605#issuecomment-3444013475
  programs.satty = {
    enable = true;
    # https://github.com/Satty-org/Satty#configuration-file
    settings = {
      general = {
        initial-tool = "crop";
        primary-highlighter = "freehand";
        fullscreen = true;
        no-window-decoration = true;
        early-exit = true;
        copy-command = "${pkgs.wl-clipboard}/bin/wl-copy";
      };
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
        settings = {
          "widget.use-xdg-desktop-portal.file-picker" = 1; # use os native file picker
        };
      };
    };
  };

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = let
        browser = "firefox-z7r.zima.desktop";
      in {
        # set default web browser
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        /*
        TODO: enable or delete
        "x-scheme-handler/chrome" = browser;
        "text/html" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/xhtml+xml" = browser;
        "application/x-extension-xhtml" = browser;
        "application/x-extension-xht" = browser;
        "x-scheme-handler/unknown" = browser;
        */
      };
    };
    desktopEntries = {
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/firefox/wrapper.nix
      "firefox-z7r.zima" = {
        name = "[z7r.zima]Firefox";
        genericName = "Web Browser (z7r.zima)";
        icon = "firefox";
        exec = "firefox -P z7r.zima --class=firefox-z7r.zima %U";
        categories = ["Network" "WebBrowser"];
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
  };

  # containers
  services.podman = {
    enable = true;
    networks.proxy = {};
  };
  systemd.user.services.pc-tor-proxy = {
    Unit = {
      After = ["podman-proxy-network.service"];
    };
    Install = {
      WantedBy = ["default.target"];
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
      "ctrl+shift+enter" = "launch --cwd=current --type=window";
    };
  };
  programs.jq.enable = true;
  programs.jqp.enable = true;
  programs.fish = {
    enable = true;
  };
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    initLua = ''
      Status:children_add(function(self)
      	local h = self._current.hovered
      	if h and h.link_to then
      		return " -> " .. tostring(h.link_to)
      	else
      		return ""
      	end
      end, 3300, Status.LEFT)

      Status:children_add(function()
      	local h = cx.active.current.hovered
      	if not h or ya.target_family() ~= "unix" then
      		return ""
      	end

      	return ui.Line {
      		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
      		":",
      		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
      		" ",
      	}
      end, 500, Status.RIGHT)

      Header:children_add(function()
      	if ya.target_family() ~= "unix" then
      		return ""
      	end
      	return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
      end, 500, Header.LEFT)
    '';
    plugins = {
      mount = pkgs.yaziPlugins.mount;
      # TODO: not work with yank.
      # wl-clipboard = pkgs.yaziPlugins.wl-clipboard;
      clipboard = pkgs.yaziPlugins.clipboard;
      smart-enter = pkgs.yaziPlugins.smart-enter;
      smart-paste = pkgs.yaziPlugins.smart-paste;
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "M";
          run = "plugin mount";
          desc = "Enter Mount Manager";
        }
        {
          on = "y";
          # TODO: not work with yank. If you want to use this plugin with yazi's default yanking behaviour you should use cx.yanked instead of tab.selected in init.lua
          # run = ["yank" "plugin wl-clipboard"];
          run = ["yank" "plugin clipboard -- --action=copy"];
          desc = "Copy to all clipboards";
        }
        {
          on = "<Enter>";
          run = "plugin smart-enter";
          desc = "Enter the child directory, or open the file";
        }
        {
          on = "p";
          run = "plugin smart-paste";
          desc = "Paste into the hovered directory or CWD";
        }
      ];
    };
  };
  programs.micro = {
    enable = true;
  };

  targets.genericLinux.nixGL.vulkan.enable = true;
  programs.zed-editor-extensions = {
    enable = true;
    # https://github.com/zed-industries/extensions/tree/main/extensions
    # https://github.com/DuskSystems/nix-zed-extensions/tree/main/generated
    packages = with pkgs.zed-extensions; [
      nix
      toml
      make
      comment
      kotlin
    ];
  };
  programs.zed-editor = {
    enable = true;
    package = pkgs.unstable.zed-editor; # wait version > 0.219 https://github.com/NixOS/nixpkgs/blob/25.11/pkgs/by-name/ze/zed-editor/package.nix#L104
    extraPackages = with pkgs; [nixd alejandra];
    mutableUserSettings = false;
    mutableUserDebug = false;
    mutableUserKeymaps = false;
    mutableUserTasks = false;
    userSettings = {
      helix_mode = true;
      which_key = {
        enabled = true;
        delay_ms = 100;
      };
      proxy = "socks5://0.0.0.0:29050";
      journal = {
        path = "~/zed-journal";
        hour_format = "hour24";
      };
      terminal = {
        shell.program = "fish";
      };
      base_keymap = "JetBrains";
      languages = {
        Nix = {
          language_servers = ["nixd" "!nil"];
          formatter = {
            external = {
              command = "alejandra";
              arguments = ["--quiet" "--"];
            };
          };
        };
      };
      lsp = {
        nixd = {
          settings = {
            # For flake.
            # "expr": "import (builtins.getFlake \"/home/lyc/workspace/CS/OS/NixOS/flakes\").inputs.nixpkgs { }   "
            # This expression will be interpreted as "nixpkgs" toplevel
            # Nixd provides package, lib completion/information from it.
            # Resource Usage: Entries are lazily evaluated, entire nixpkgs takes 200~300MB for just "names".
            #                Package documentation, versions, are evaluated by-need.
            nixpkgs.expr = ''import (builtins.getFlake (builtins.toString ${config.home.homeDirectory}/nix-config)).inputs.nixpkgs { }'';
            formatting.command = ["alejandra" "--quiet" "--"];
            # Control the diagnostic system
            diagnostic.suppress = ["sema-extra-with"];
            # Tell the language server your desired option set, for completion
            # This is lazily evaluated.
            options = {
              # Map of eval information
              # By default, this entriy will be read from `import <nixpkgs> { }`
              # You can write arbitary nix expression here, to produce valid "options" declaration result.
              #
              # *NOTE*: Replace "<name>" below with your actual configuration name.
              # If you're unsure what to use, you can verify with `nix repl` by evaluating
              # the expression directly.
              #
              nixos.expr = ''(builtins.getFlake (builtins.toString ${config.home.homeDirectory}/nix-config)).nixosConfigurations.test-desktop.options'';
              nixos_args.expr = ''(builtins.getFlake (builtins.toString ${config.home.homeDirectory}/nix-config)).nixosConfigurations.test-desktop._module.specialArgs'';

              # Before configuring Home Manager options, consider your setup:
              # Which command do you use for home-manager switching?
              #
              #  A. home-manager switch --flake .#... (standalone Home Manager)
              #  "expr": "(builtins.getFlake (builtins.toString ./.)).homeConfigurations.<name>.options"
              #  B. nixos-rebuild switch --flake .#... (NixOS with integrated Home Manager)
              #  "expr": "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.<name>.options.home-manager.users.type.getSubOptions []"
              #
              # Configuration examples for both approaches are shown below.
              home_manager.expr = ''(builtins.getFlake (builtins.toString ${config.home.homeDirectory}/nix-config)).legacyPackages.x86_64-linux.homeConfigurations."zx@test-desktop".options'';
            };
          };
        };
      };
    };
    userKeymaps = [
      {
        context = "(VimControl && !menu)";
        bindings = {
          space = null;
          ctrl-w = null;
        };
      }
    ];
  };

  # TODO:
  # [x] hx --tutor g441g
  # [ ] https://tomgroenwoldt.github.io/helix-shortcut-quiz/
  # [ ] https://nik-rev.github.io/helix-golf/
  programs.helix = {
    enable = true;
    extraPackages = with pkgs; [nixd yaml-language-server docker-compose-language-service];
    settings = {
      editor = {
        shell = ["fish" "-c"];
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
          args = ["--semantic-tokens=true"];
          config.nixd = let
            myFlake = ''(builtins.getFlake "${config.home.homeDirectory}/nix-config"'';
            nixosOpts = "${myFlake}.nixosConfigurations.test-desktop.options";
          in {
            nixpkgs.expr = "import ${myFlake}.inputs.nixpkgs { }";
            formatting.command = ["${lib.getExe pkgs.nixfmt-rfc-style}"];
            options = {
              nixos.expr = nixosOpts;
              home-manager.expr = "${nixosOpts}.home-manager.users.type.getSubOptions [ ]";
            };
          };
        };
      };
    };
  };

  # index
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/nix-config";

    #clean = {
    #  enable = true;
    #  extraArgs = "--keep-since 4d --keep 3";
    #};
  };

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    settings = {
      appLauncher = {
        autoPasteClipboard = false;
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
        clipboardWrapText = true;
        customLaunchPrefix = "";
        customLaunchPrefixEnabled = false;
        enableClipPreview = true;
        enableClipboardHistory = true;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        iconMode = "tabler";
        ignoreMouseInput = false;
        pinnedApps = [];
        position = "top_center";
        screenshotAnnotationTool = "";
        showCategories = true;
        showIconBackground = false;
        sortByMostUsed = true;
        terminalCommand = "kitty -e";
        useApp2Unit = false;
        viewMode = "list";
      };
      audio = {
        cavaFrameRate = 30;
        mprisBlacklist = [];
        preferredPlayer = "";
        visualizerType = "linear";
        volumeFeedback = false;
        volumeOverdrive = false;
        volumeStep = 5;
      };
      bar = {
        autoHideDelay = 500;
        autoShowDelay = 150;
        barType = "simple";
        # backgroundOpacity = 1;
        # capsuleOpacity = 1;
        density = "default";
        displayMode = "always_visible";
        floating = false;
        frameRadius = 12;
        frameThickness = 8;
        hideOnOverview = false;
        marginHorizontal = 5;
        marginVertical = 5;
        monitors = [];
        outerCorners = false;
        position = "top";
        screenOverrides = [];
        showCapsule = false;
        showOutline = false;
        useSeparateOpacity = false;
        widgets = {
          left = [
            {
              id = "Workspace";
              characterCount = 2;
              colorizeIcons = false;
              emptyColor = "secondary";
              enableScrollWheel = true;
              focusedColor = "primary";
              followFocusedScreen = false;
              groupedBorderOpacity = 1;
              hideUnoccupied = true;
              iconScale = 0.8;
              labelMode = "index";
              occupiedColor = "secondary";
              pillSize = 0.6;
              reverseScroll = false;
              showApplications = false;
              showBadge = true;
              showLabelsOnlyWhenOccupied = true;
              unfocusedIconsOpacity = 1;
            }
            {
              id = "ActiveWindow";
              colorizeIcons = false;
              hideMode = "hidden";
              maxWidth = 145;
              scrollingMode = "hover";
              showIcon = true;
              useFixedWidth = false;
            }
          ];
          center = [
            {
              id = "MediaMini";
              compactMode = false;
              compactShowAlbumArt = true;
              compactShowVisualizer = false;
              hideMode = "hidden";
              hideWhenIdle = false;
              maxWidth = 145;
              panelShowAlbumArt = true;
              panelShowVisualizer = true;
              scrollingMode = "hover";
              showAlbumArt = false;
              showArtistFirst = true;
              showProgressRing = true;
              showVisualizer = false;
              useFixedWidth = false;
              visualizerType = "linear";
            }
            {
              id = "Clock";
              clockColor = "primary";
              customFont = "";
              formatHorizontal = "HH:mm - dd.MM(ddd)";
              formatVertical = "HH mm - dd MM";
              tooltipFormat = "HH:mm - dd.MM(ddd)";
              useCustomFont = false;
            }
            {
              id = "plugin:privacy-indicator";
              defaultSettings = {
                hideInactive = false;
                removeMargins = false;
              };
            }
          ];
          right = [
            {
              id = "LockKeys";
              showCapsLock = true;
              capsLockIcon = "arrow-big-up-lines-filled";
              hideWhenOff = true;
              showNumLock = true;
              numLockIcon = "numbers";
              showScrollLock = false;
              scrollLockIcon = "letter-s";
            }
            {
              id = "KeyboardLayout";
              displayMode = "forceOpen";
              showIcon = false;
            }
            {
              id = "plugin:pomodoro";
              defaultSettings = {
                autoStartBreaks = false;
                autoStartWork = false;
                longBreakDuration = 15;
                sessionsBeforeLongBreak = 4;
                shortBreakDuration = 5;
                workDuration = 25;
              };
            }
            {
              id = "plugin:keybind-cheatsheet";
              defaultSettings = {
                autoHeight = true;
                cheatsheetData = [];
                columnCount = 3;
                detectedCompositor = "";
                hyprlandConfigPath = "~/.config/hypr/hyprland.conf";
                modKeyVariable = "$mod";
                niriConfigPath = "~/.config/niri/config.kdl";
                windowHeight = 0;
                windowWidth = 1400;
              };
            }
            {
              id = "Tray";
              colorizeIcons = false;
              drawerEnabled = true;
              hidePassive = false;
              blacklist = [];
              pinned = [];
            }
            {
              id = "SystemMonitor";
              compactMode = true;
              useMonospaceFont = true;
              usePrimaryColor = false;
              showCpuTemp = true;
              showCpuFreq = false;
              showCpuUsage = true;
              showDiskUsage = false;
              showDiskAvailable = false;
              showDiskUsageAsPercent = false;
              showSwapUsage = false;
              diskPath = "/";
              showGpuTemp = false;
              showLoadAverage = false;
              showMemoryAsPercent = false;
              showMemoryUsage = true;
              showNetworkStats = false;
            }
            {
              id = "Volume";
              displayMode = "onhover";
              middleClickCommand = "pwvucontrol || pavucontrol";
            }
            {
              id = "Brightness";
              displayMode = "onhover";
            }
            {
              id = "NotificationHistory";
              hideWhenZero = false;
              hideWhenZeroUnread = false;
              showUnreadBadge = true;
              unreadBadgeColor = "primary";
            }
            {
              id = "Network";
              displayMode = "onhover";
            }
            {
              id = "ControlCenter";
              useDistroLogo = true;
              enableColorization = true;
              colorizeSystemIcon = "primary";
              colorizeDistroLogo = false;
              customIconPath = "";
              icon = "noctalia";
            }
          ];
        };
      };
      brightness = {
        brightnessStep = 5;
        enableDdcSupport = false;
        enforceMinimum = true;
      };
      calendar = {
        cards = [
          {
            id = "calendar-header-card";
            enabled = true;
          }
          {
            id = "calendar-month-card";
            enabled = true;
          }
          {
            id = "weather-card";
            enabled = true;
          }
        ];
      };
      colorSchemes = {
        darkMode = true;
        generationMethod = "tonal-spot";
        manualSunrise = "06:30";
        manualSunset = "18:30";
        monitorForColors = "";
        predefinedScheme = "Noctalia (default)";
        schedulingMode = "off";
        useWallpaperColors = false;
      };
      controlCenter = {
        diskPath = "/";
        position = "close_to_bar_button";
        shortcuts = {
          left = [
            {id = "Network";}
            {id = "Bluetooth";}
            {id = "WallpaperSelector";}
          ];
          right = [
            {id = "Notifications";}
            {id = "PowerProfile";}
            {id = "KeepAwake";}
            {id = "NightLight";}
          ];
        };
        cards = [
          {
            id = "profile-card";
            enabled = true;
          }
          {
            id = "shortcuts-card";
            enabled = true;
          }
          {
            id = "audio-card";
            enabled = true;
          }
          {
            id = "weather-card";
            enabled = false;
          }
          {
            id = "media-sysmon-card";
            enabled = true;
          }
          {
            id = "brightness-card";
            enabled = false;
          }
        ];
      };
      desktopWidgets = {
        enabled = false;
        gridSnap = false;
        monitorWidgets = [];
      };
      dock.enabled = false;
      general = {
        allowPanelsOnScreenWithoutBar = true;
        allowPasswordWithFprintd = false;
        animationDisabled = false;
        animationSpeed = 1;
        autoStartAuth = false;
        avatarImage = "/home/zx/.face";
        boxRadiusRatio = 1;
        compactLockScreen = false;
        dimmerOpacity = 0.6;
        enableLockScreenCountdown = true;
        enableShadows = true;
        forceBlackScreenCorners = false;
        iRadiusRatio = 1;
        language = "";
        lockOnSuspend = true;
        lockScreenCountdownDuration = 10000;
        radiusRatio = 1;
        scaleRatio = 1;
        screenRadiusRatio = 1;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        showChangelogOnStartup = true;
        showHibernateOnLockScreen = false;
        showScreenCorners = false;
        showSessionButtonsOnLockScreen = true;
        telemetryEnabled = true; # TODO: disable after release
      };
      hooks = {
        darkModeChange = "";
        enabled = false;
        performanceModeDisabled = "";
        performanceModeEnabled = "";
        screenLock = "";
        screenUnlock = "";
        session = "";
        startup = "";
        wallpaperChange = "";
      };
      location = {
        analogClockInCalendar = false;
        firstDayOfWeek = 1;
        hideWeatherCityName = false;
        hideWeatherTimezone = false;
        name = "krasnodar";
        showCalendarEvents = true;
        showCalendarWeather = true;
        showWeekNumberInCalendar = false;
        use12hourFormat = false;
        useFahrenheit = false;
        weatherEnabled = true;
        weatherShowEffects = true;
      };
      network = {
        bluetoothDetailsViewMode = "grid";
        bluetoothHideUnnamedDevices = false;
        bluetoothRssiPollIntervalMs = 10000;
        bluetoothRssiPollingEnabled = false;
        wifiDetailsViewMode = "grid";
        wifiEnabled = true;
      };
      nightLight = {
        enabled = true;
        autoSchedule = true;
        forced = false;
        manualSunrise = "06:30";
        manualSunset = "18:30";
        dayTemp = "6500";
        nightTemp = "4000";
      };
      notifications = {
        # backgroundOpacity = 1;
        batteryCriticalThreshold = 5;
        batteryWarningThreshold = 20;
        criticalUrgencyDuration = 15;
        enableKeyboardLayoutToast = true;
        enableMediaToast = false;
        enabled = true;
        location = "top_right";
        lowUrgencyDuration = 3;
        monitors = [];
        normalUrgencyDuration = 8;
        overlayLayer = true;
        respectExpireTimeout = false;
        saveToHistory = {
          low = true;
          normal = true;
          critical = true;
        };
        sounds = {
          enabled = false;
          criticalSoundFile = "";
          excludedApps = "discord,firefox,chrome,chromium,edge";
          lowSoundFile = "";
          normalSoundFile = "";
          separateSounds = false;
          volume = 0.5;
        };
      };
      osd = {
        autoHideMs = 2000;
        # backgroundOpacity = 1;
        enabled = true;
        enabledTypes = [0 1 2 4];
        location = "top_right";
        monitors = [];
        overlayLayer = true;
      };
      sessionMenu = {
        largeButtonsStyle = true;
        showHeader = true;
        showNumberLabels = true;
        enableCountdown = true;
        largeButtonsLayout = "single-row";
        countdownDuration = 10000;
        position = "center";
        powerOptions = [
          {
            action = "lock";
            command = "";
            countdownEnabled = true;
            enabled = true;
          }
          {
            action = "suspend";
            command = "";
            countdownEnabled = true;
            enabled = false;
          }
          {
            action = "hibernate";
            command = "";
            countdownEnabled = true;
            enabled = false;
          }
          {
            action = "reboot";
            command = "";
            countdownEnabled = true;
            enabled = true;
          }
          {
            action = "logout";
            command = "";
            countdownEnabled = true;
            enabled = true;
          }
          {
            action = "shutdown";
            command = "";
            countdownEnabled = true;
            enabled = true;
          }
        ];
      };
      systemMonitor = {
        cpuCriticalThreshold = 90;
        cpuPollingInterval = 1000;
        cpuWarningThreshold = 80;
        criticalColor = "";
        diskAvailCriticalThreshold = 10;
        diskAvailWarningThreshold = 20;
        diskCriticalThreshold = 90;
        diskPollingInterval = 3000;
        diskWarningThreshold = 80;
        enableDgpuMonitoring = false;
        externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
        gpuCriticalThreshold = 90;
        gpuPollingInterval = 3000;
        gpuWarningThreshold = 80;
        loadAvgPollingInterval = 3000;
        memCriticalThreshold = 90;
        memPollingInterval = 1000;
        memWarningThreshold = 80;
        networkPollingInterval = 1000;
        swapCriticalThreshold = 90;
        swapWarningThreshold = 80;
        tempCriticalThreshold = 90;
        tempWarningThreshold = 80;
        useCustomColors = false;
        warningColor = "";
      };
      templates = {
        activeTemplates = [];
        enableUserTheming = false;
      };
      ui = {
        bluetoothDetailsViewMode = "grid";
        bluetoothHideUnnamedDevices = false;
        boxBorderEnabled = false;
        # panelBackgroundOpacity = 1;
        # fontDefault = "Roboto";
        # fontFixed = "DejaVu Sans Mono";
        networkPanelView = "wifi";
        fontDefaultScale = 1;
        fontFixedScale = 1;
        panelsAttachedToBar = true;
        settingsPanelMode = "attached";
        tooltipsEnabled = true;
        wifiDetailsViewMode = "grid";
      };
      wallpaper = {
        automationEnabled = false;
        useSolidColor = false;
        # solidColor = "#1a1a2e";
        directory = "/home/zx/Pictures/Wallpapers";
        enableMultiMonitorDirectories = false;
        enabled = true;
        fillColor = "#000000";
        fillMode = "crop";
        hideWallpaperFilenames = false;
        monitorDirectories = [];
        overviewEnabled = false;
        panelPosition = "follow_bar";
        randomIntervalSec = 300;
        setWallpaperOnAllMonitors = true;
        showHiddenFiles = false;
        sortOrder = "name";
        transitionDuration = 1500;
        transitionEdgeSmoothness = 0.05;
        transitionType = "random";
        useWallhaven = false;
        viewMode = "single";
        wallhavenApiKey = "";
        wallhavenCategories = "111";
        wallhavenOrder = "desc";
        wallhavenPurity = "100";
        wallhavenQuery = "";
        wallhavenRatios = "";
        wallhavenResolutionHeight = "";
        wallhavenResolutionMode = "atleast";
        wallhavenResolutionWidth = "";
        wallhavenSorting = "relevance";
        wallpaperChangeMode = "random";
      };
    };
  };

  programs.niri = {
    enable = true;
    settings = {
      # disable hotkey overlay on startup
      hotkey-overlay.skip-at-startup = true;
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

        /*
        SEE https://github.com/AvengeMedia/DankMaterialShell/blob/master/distro/nix/niri.nix
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

        "Print".action.screenshot = {};
        # "Ctrl+Print".action.screenshot-screen = {};
        # "Alt+Print".action.screenshot-window = {};
        "Ctrl+Print" = {
          action = spawn "flameshot" "gui";
          hotkey-overlay.title = "Take screenshot(FlameShot)";
        };
        "Alt+Print" = {
          action = spawn "take-screen";
          hotkey-overlay.title = "Take screenshot(Satty)";
        };

        # The quit action will show a confirmation dialog to avoid accidental exits.
        "Mod+Shift+E".action = quit;

        # Powers off the monitors. To turn them back on, do any input like
        # moving the mouse or pressing any other key.
        "Mod+Shift+P".action = power-off-monitors;
      };
    };
  };
}
