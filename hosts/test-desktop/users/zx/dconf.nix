# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "apps/seahorse/listing" = {
      keyrings-selected = [ "secret-service:///org/freedesktop/secrets/collection/login" ];
    };

    "apps/seahorse/windows/key-manager" = {
      height = 957;
      width = 600;
    };

    "ca/desrt/dconf-editor" = {
      saved-pathbar-path = "/org/gnome/desktop/interface/color-scheme";
      saved-view = "/org/gnome/desktop/interface/color-scheme";
      window-height = 965;
      window-is-maximized = false;
      window-width = 488;
    };

    "one/alynx/showmethekey" = {
      first-time = false;
    };

    "org/blueman/general" = {
      window-properties = [ 1065 515 0 0 ];
    };

    "org/erikreider/swaync" = {
      dnd-state = false;
    };

    "org/gnome/Console" = {
      last-window-maximised = true;
      last-window-size = mkTuple [ 732 528 ];
    };

    "org/gnome/control-center" = {
      last-panel = "printers";
      window-state = mkTuple [ 980 640 false ];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "System" "Utilities" "YaST" "Pardus" ];
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = [ "X-Pardus-Apps" ];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/System" = {
      apps = [ "org.gnome.baobab.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Logs.desktop" "org.gnome.SystemMonitor.desktop" ];
      name = "X-GNOME-Shell-System.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "org.gnome.Decibels.desktop" "org.gnome.Connections.desktop" "org.gnome.Papers.desktop" "org.gnome.font-viewer.desktop" "org.gnome.Loupe.desktop" ];
      name = "X-GNOME-Shell-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = [ "X-SuSE-YaST" ];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/input-sources" = {
      sources = [ (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      toolkit-accessibility = false;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "firefox" "gnome-printers-panel" ];
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-printers-panel" = {
      application-id = "gnome-printers-panel.desktop";
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      migrated-gtk-settings = true;
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [ 890 550 ];
      maximized = true;
    };

    "org/gnome/papers" = {
      night-mode = false;
    };

    "org/gnome/papers/default" = {
      annot-color = "yellow";
      continuous = true;
      dual-page = false;
      dual-page-odd-left = false;
      enable-spellchecking = true;
      show-sidebar = true;
      sizing-mode = "automatic";
      window-height = 1048;
    };

    "org/gnome/shell" = {
      welcome-dialog-last-shown-version = "49.2";
    };

    "org/gnome/shell/world-clocks" = {
      locations = [];
    };

    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 0.9215686321258545 0.3019607961177826 0.29411765933036804 1.0 ]) ];
      selected-color = mkTuple [ true 0.9215686321258545 0.3019607961177826 0.29411765933036804 1.0 ];
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = false;
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 171;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 26 23 ];
      window-size = mkTuple [ 1231 979 ];
    };

  };
}
