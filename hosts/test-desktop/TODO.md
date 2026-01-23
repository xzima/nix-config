# Task list

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
- настроить yazi
    - копирование файлов для yazi file://github.com/XYenon/clipboard.yazi
    - yazi должен работать одинаково на всех раскладках
- flameshot
- настроить скриншоты
    - https://github.com/flameshot-org/flameshot/issues/3605
    - https://danklinux.com/docs/dankmaterialshell/keybinds-ipc#niri
    - https://danklinux.com/docs/dankmaterialshell/cli-screenshot
- обои должны быть привязаны к времени суток
    - https://github.com/hexive/sunpaper
    - https://github.com/rohan-shettyy/Wallpaper-Wizard
- настроить half-qwerty keyboard layout https://github.com/jorissteyn/xkb-halfqwerty

- calc
- htop btop
- 7zip bat ripgrep yq tar rsync ffmpeg neofetch less tail

- trilium
- jellyfin

- bitwarden - перенос паролей из keeweb
    - https://github.com/dani-garcia/vaultwarden
- telegram
    - telegram-desktop
    - tg
- betterbird -- https://gist.github.com/drupol/a4452934b5bed4956000d55699af074e

- image viewer [feh](https://feh.finalrewind.org)
- pdf reader -- ocular [zathura](https://pwmt.org/projects/zathura)
- koreader

- ventoy
- gparted -- disk manager
- Filelight — приложение для визуализации использования дискового пространства
- kde connect

- mattermost slack
- onlyoffice

- scanner -- gscan2pdf skanlite
- caps gui -- printers
- pantum-driver

- kubectl tea

- tailscale
- docker rootless
    - настроить docker rootless
        - перевести pc-tor-proxy на docker rootless
        - попробовать пробросить конфиги напрямую из ~/nix-config
            - пробросить конфиг для pc-tor-proxy напрямую из с использованием agenix

- vlc -- media
- noctalia shell configuration
    - установить медиаплеер и настроить интеграцию -- vlc, mpv
    - screenshot annotation tool уже есть в настройках вызов из clipboard -- gradia satty
    - настроить docker mini tool
    - настроить sistem monitor -- resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor
    - разобраться с keyboard cheatsheet
- проблемы jetbrains
    - при использовании markdown плагина зависает
    - заменить цвет background как в основной теме
    - поправить размер кнопок regreet
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

- amnezia
- chrome | tor browser | yandex browser
- wofi
    - https://hg.sr.ht/~scoopta/wofi
- настроить youtube
    - [programs.firefoxpwa](https://pwasforfirefox.filips.si/)
    - настроить amnezia для этого pwa
    - протестировать on-screen display cm noctalia
    - установить и настроить https://github.com/pltanton/autobrowser/tree/master или альтернативу как браузер по умолчанию
    - для дефолтного браузера внутри autobrowser нужно установить приложение типа junction
        - использовать скрипт на базе wofi или альтернативы для организации селектора браузера
            - https://github.com/obvionaoe/rofi-browser
            - использовать апи xdg desktop https://git.outfoxxed.me/quickshell/quickshell/src/branch/master/src/core/desktopentry.cpp

- any desk -- удаленный рабочий стол
- droidcam -- телефон как камера
- virtualbox
- drowio
- zoom
- gimp
- weasis -- DICOM viewer for medical images

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
- настроить xdg-desktop-portals
    - file and directory chose https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser + yazi
    - tools
        - https://github.com/bilelmoussaoui/ashpd
        - https://apps.gnome.org/ru/Dspy/
        - docs https://flatpak.github.io/xdg-desktop-portal/docs/writing-a-new-backend.html
        - sdk js https://github.com/particle-iot/node-dbus-next
    - url selector with dmenu
        - https://github.com/pltanton/autobrowser/tree/master
        - https://hg.sr.ht/~scoopta/wofi
    - Screenshot and ScreenCast https://github.com/emersion/xdg-desktop-portal-wlr
        - wofi integration ```https://github.com/emersion/xdg-desktop-portal-wlr/issues/124```
    - Settings, RemoteDesktop, ScreenCast, ScreenShot
        - https://github.com/waycrate/xdg-desktop-portal-luminous
    - redirect
        - https://github.com/Decodetalkers/xdg-desktop-portal-shana

## INFO

- альтернатива dms и noctalia [ashell](https://github.com/MalpenZibo/ashell)
