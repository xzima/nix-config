# Task list

- настроить xdg-desktop-portals
    - https://apps.gnome.org/ru/Dspy/
    - file and directory chose https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser + yazi
    - url selector with dmenu
        - https://codeberg.org/dnkl/fuzzel
        - https://github.com/Cloudef/bemenu
        - https://github.com/philj56/tofi
        - https://hg.sr.ht/~scoopta/wofi
    - Screenshot and ScreenCast https://github.com/emersion/xdg-desktop-portal-wlr
        - wofi integration https://github.com/emersion/xdg-desktop-portal-wlr/issues/124
- try to replace bootloader with Limine
    - https://www.youtube.com/watch?v=b_BAStWd1aw
      ```nix
      boot.loader.systemd-boot.enable = false; # Disable systemd-boot if enabled
      boot.loader.grub.enable = false; # Disable GRUB if enabled
      
      boot.loader.limine = {
      enable = true;
      # Optional: Install for BIOS if needed (defaults to EFI)
      # efiSupport = true;
      # biosSupport = true;
      # Optional: Customize appearance (e.g., with Stylix)
      # style.wallpapers = [ /path/to/your/wallpaper.png ];
      # style.wallpaperStyle = "centered";
      # extraConfig = ''
      #   remember_last_entry: yes
      # '';
      };
      ```
- настроить junction или найти альтернативу
- попробовать пробросить конфиги напрямую из ~/nix-config
- настроить скриншоты
    - https://github.com/flameshot-org/flameshot/issues/3605
    - https://danklinux.com/docs/dankmaterialshell/keybinds-ipc#niri
    - https://danklinux.com/docs/dankmaterialshell/cli-screenshot
- обои должны быть привязаны к времени суток
    - разработать свою тему https://docs.noctalia.dev/development/colorscheme/
        - настроить цветовую схему под обои, idea и стандартные темные темы
- tailscale
- betterbird -- https://gist.github.com/drupol/a4452934b5bed4956000d55699af074e
- telegram
- trilium
- amnezia
- any desk -- удаленный рабочий стол
- bitwarden
- droidcam -- телефон как камера
- Filelight — приложение для визуализации использования дискового пространства
- flameshot
- scanner -- gscan2pdf skanlite
- gimp
- chrome | tor browser | yandex browser
- image viewer [feh](https://feh.finalrewind.org)
- htop btop
- jellyfin
- calc
- kde connect
- koreader
- mattermost slack
- pdf reader -- ocular [zathura](https://pwmt.org/projects/zathura)
- onlyoffice
- virtualbox
- ventoy
- vlc -- media
- weasis
- zoom
- gparted -- disk manager
- caps gui -- printers
- 7zip bat ripgrep yq tea tar rsync ffmpeg pantum-driver neofetch less tail kubectl
- drowio
- docker rootless
- настроить yazi
    - копирование файлов для yazi file://github.com/XYenon/clipboard.yazi
    - yazi должен работать одинаково на всех раскладках
- noctalia shell configuration
    - screenshot annotation tool уже есть в настройках вызов из clipboard -- gradia satty
    - настроить docker mini tool - нужен docker rootless
    - настроить sistem monitor -- resources || missioncenter || jdsystemmonitor || corestats ||
      system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor ||
      ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor
    - установить медиаплеер и настроить интеграцию -- vlc, mpv
    - протестировать on-screen display
    - разобраться с keyboard cheatsheet
- проблемы jetbrains
    - при использовании markdown плагина зависает
    - заменить цвет background как в основной теме
- проблемы zed
    - интеграция с git - нужна интеграция с lazygit
    - нужен редактор git conventional commit
    - цветовая схема для кода должна быть как в idea
    - настроить kotlin rust
- проблемы helix
    - интеграция с git - нужна интеграция с lazygit
    - нужен редактор git conventional commit -- commit-lsp
    - цветовая схема для кода должна быть как в idea
    - настроить kotlin rust

## MAIN

- desktop manager
- launcher
- exit session menu
- layout widget with capslock
- clock
- wifi
- clipboard manager
- default apps
- printer on gtk and qt apps
    - gtk apps broken
        - https://github.com/NixOS/nixpkgs/issues/475644
        - https://github.com/NixOS/nixpkgs/issues/369463
-

## DONE

- настроить desktop manager
    - взять из dms и пробросить цвета
    - найти другой с удобной
      настройкой https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/programs/regreet.nix
- настроить vimium->firefox https://addons.mozilla.org/en-US/firefox/addon/vimium-ff/
- подобрать цвета для stylix
    - https://colorffy.com/dark-theme-generator?colors=4caf50-0f160d&success=21498A&warning=A87A2A&danger=9C2121&info=4cacaf&primaryCount=6&surfaceCount=8
    - https://github.com/medanimohamedakram/Dotfiles/blob/main/greetd/regreet.toml
    - https://nix-community.github.io/stylix/configuration.html
    - https://github.com/TophC7/mix.nix
    - https://github.com/InioX/matugen
    - https://github.com/InioX/matugen-themes
- настроить noctalia-shell
    - https://github.com/noctalia-dev/noctalia-shell
    - https://docs.noctalia.dev/getting-started/nixos/
- настроить https://github.com/nix-community/nh
    - https://github.com/efremovich/nixos-config/blob/main/nixos/modules/nh.nix
- настроить zed
    - настроить nix extension https://github.com/zed-extensions/nix
        - настроить nixd
            - https://nixcats.org/nix_LSPS.html
            - https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
        - настроить alejandra https://github.com/kamadorueda/alejandra
- починить idea wayland
    - написать overlay с переопределением jetbrains idea
    - починить url откуда качается jetbrains idea
    - принудительно запускать в режиме wayland
    - решить проблему с темной темой header-ов

## INFO

- альтернатива dms и noctalia [ashell](https://github.com/MalpenZibo/ashell)
