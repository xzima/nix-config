{ flake, inputs, perSystem, config, pkgs, lib, ... }:
{

  imports = [
    ./dconf.nix
    #flake.homeModules.shell
    inputs.nix-index-database.homeModules.nix-index
    #    inputs.niri.homeModules.niri
  ];

  #  nixpkgs.overlays = [
  #    inputs.niri.overlays.niri
  #  ];

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
            url = builtins.replaceStrings [ "download.jetbrains.com" ] [ "download-cdn.jetbrains.com" ] (builtins.head old.src.urls);
            sha256 = old.src.outputHash;
          };
        });
      in
      ideaOverAttr
    )
    junction
    zip
    unzip
    git
    dconf2nix
    ulauncher
    gnome-tweaks
    gnomeExtensions.paperwm
    gnomeExtensions.clipboard-indicator
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
        { on = "M"; run = "plugin mount"; desc = "Enter Mount Manager"; }
      ];
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
}
