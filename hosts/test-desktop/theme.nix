{ flake, inputs, hostName, perSystem, config, modulesPath, pkgs, lib, ... }:
let
  # source https://colorffy.com/dark-theme-generator
  /** Base colors */
  dark-a0 = "#000000";
  light-a0 = "#ffffff";

  /** Theme primary colors */
  primary-a0 = "#4caf50";
  primary-a10 = "#63b863";
  primary-a20 = "#79c176";
  primary-a30 = "#8dca89";
  primary-a40 = "#a0d39c";
  primary-a50 = "#b4dcb0";

  /** Theme surface colors */
  surface-a0 = "#0f160d";
  surface-a10 = "#252b24";
  surface-a20 = "#3c423b";
  surface-a30 = "#555a54";
  surface-a40 = "#6f736e";
  surface-a50 = "#8a8d89";
  surface-a60 = "#a6a9a5";
  surface-a70 = "#c3c5c2";
  surface-a80 = "#e1e1e0";
  surface-a90 = "#ffffff";

  /** Theme tonal surface colors */
  surface-tonal-a0 = "#162315";
  surface-tonal-a10 = "#2b382a";
  surface-tonal-a20 = "#424e41";
  surface-tonal-a30 = "#5b6459";
  surface-tonal-a40 = "#747c73";
  surface-tonal-a50 = "#8e958d";
  surface-tonal-a60 = "#a9afa8";
  surface-tonal-a70 = "#c5c9c4";

  /** Success colors */
  success-a0 = "#21498a";
  success-a10 = "#4077d1";
  success-a20 = "#92b2e5";

  /** Warning colors */
  warning-a0 = "#a87a2a";
  warning-a10 = "#d7ac61";
  warning-a20 = "#ecd7b2";

  /** Danger colors */
  danger-a0 = "#9c2121";
  danger-a10 = "#d94a4a";
  danger-a20 = "#eb9e9e";

  /** Info colors */
  info-a0 = "#4cacaf";
  info-a10 = "#92cecf";
  info-a20 = "#d9eeee";
in
{

  stylix = {
    enable = true;
    polarity = "dark";
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/material-darker.yaml";
    base16Scheme = {
      base00 = surface-a0;
      base01 = surface-tonal-a0;
      base02 = surface-a40;
      base03 = surface-a50;
      base04 = surface-a60;
      base05 = surface-a70;
      base06 = surface-a80;
      base07 = surface-a90;
      base08 = danger-a20;
      base09 = warning-a0;
      base0A = warning-a10;
      base0B = primary-a0;
      base0C = primary-a20;
      base0D = success-a10;
      base0E = success-a20;
      base0F = danger-a0;
    };
    targets.regreet.enable = false;
  };
  programs.regreet = {
    settings.GTK.application_prefer_dark_theme = true;
    # https://github.com/medanimohamedakram/Dotfiles/blob/main/greetd/regreet.toml
    extraCss = ''
      * {
        all: unset;
      }

      picture {
        filter: blur(2rem);
      }

      frame.background {
        background: alpha(${surface-a0}, .92);
        color: ${primary-a40};
        border-radius: 24px;
        box-shadow: 0 0 12px 2px alpha(${dark-a0}, .9);
      }

      frame.background>grid>label:first-child {
        font-size: 1.2rem;
        padding: 6px;
      }

      frame.background.top {
        font-size: 1.2rem;
        padding: 8px;
        background: ${surface-a0};
        border-radius: 0;
        border-bottom-left-radius: 24px;
        border-bottom-right-radius: 24px;
      }

      box.horizontal>button.default.suggested-action.text-button {
        background: ${surface-tonal-a10};
        color: ${primary-a40};
        padding: 12px;
        margin: 0 8px;
        border-radius: 12px;
        box-shadow: 0 0 2px 1px alpha(${dark-a0}, .6);
        transition: background .3s ease-in-out;
      }

      box.horizontal>button.default.suggested-action.text-button:hover {
        background: ${primary-a0};
        color: ${surface-tonal-a0};
      }

      box.horizontal>button.text-button {
        background: alpha(${danger-a20}, .1);
        color: ${danger-a0};
        padding: 12px;
        border-radius: 12px;
        transition: background .3s ease-in-out;
      }

      box.horizontal>button.text-button:hover {
        background: alpha(${danger-a20}, .3);
      }

      box.bottom.vertical>box.horizontal>button.destructive-action.text-button {
        background: ${surface-tonal-a0};
        color: ${danger-a0};
        padding: 12px;
        border-radius: 12px;
        transition: background .3s ease-in-out;
      }

      box.bottom.vertical>box.horizontal>button.destructive-action.text-button:hover {
        background: ${danger-a20};
        color: ${danger-a0};
      }

      combobox {
        background: ${surface-tonal-a0};
        color: ${primary-a40};
        border-radius: 12px;
        padding: 12px;
        box-shadow: 0 0 0 1px alpha(${dark-a0}, .6);
      }

      combobox:disabled {
        background: ${surface-tonal-a0};
        color: alpha(${primary-a50}, .6);
        border-radius: 12px;
        padding: 12px;
        box-shadow: none;
      }

      modelbutton.flat {
        background: ${surface-tonal-a0};
        padding: 6px;
        margin: 2px;
        border-radius: 8px;
        border-spacing: 6px;
      }

      modelbutton.flat:hover {
        background: alpha(${info-a10}, .2);
      }

      button.image-button.toggle {
        margin-right: 36px;
        padding: 12px;
        border-radius: 12px;
      }

      button.image-button.toggle:hover {
        background: ${surface-a0};
      }

      button.image-button.toggle:disabled {
        background: ${surface-tonal-a0};
        color: alpha(${primary-a50}, .6);
        margin-right: 36px;
        padding: 12px;
        border-radius: 12px;
      }

      combobox>popover {
        background: ${surface-tonal-a0};
        color: ${primary-a50};
        border-radius: 12px;
        border: 1px solid ${info-a10};
        padding: 2px 12px;
      }

      combobox>popover>contents {
        padding: 2px;
      }

      combobox:hover {
        background: alpha(${info-a10}, .2);
      }

      entry.password {
        border: 2px solid ${primary-a0};
        border-radius: 12px;
        padding: 12px;
      }

      entry.password:hover {
        border: 2px solid ${primary-a0};
      }

      tooltip {
        background: ${surface-a0};
        color: ${primary-a40};
        padding: 12px;
        border-radius: 12px;
      }
    '';
  };
}
