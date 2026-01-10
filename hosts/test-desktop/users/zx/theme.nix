{ flake, inputs, perSystem, config, pkgs, lib, ... }:
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

    # wait https://github.com/nix-community/stylix/issues/249
    targets.micro.enable = false;
    # Override
    targets.noctalia-shell.enable = false;

    targets.firefox = {
      firefoxGnomeTheme.enable = true;
      profileNames = [ "default" "z7r.zima" ];
    };
  };

  # https://github.com/noctalia-dev/noctalia-shell/blob/main/Assets/MatugenTemplates/noctalia.json
  programs.noctalia-shell = {
    colors = with config.programs.matugen.theme.colors; {
      mPrimary = primary-a0;
      mOnPrimary = surface-tonal-a0;

      mSecondary = success-a20;
      mOnSecondary = surface-tonal-a0;

      mHover = primary-a20;
      mOnHover = surface-tonal-a0;

      mTertiary = info-a10;
      mOnTertiary = surface-tonal-a0;

      mSurface = surface-a0;
      mOnSurface = primary-a40;

      mSurfaceVariant = surface-tonal-a0;
      mOnSurfaceVariant = primary-a50;

      mOutline = surface-tonal-a10;
      mShadow = dark-a0;

      mError = danger-a20;
      mOnError = danger-a0;
      /*{
          "mPrimary": "{{colors.primary.default.hex}}",
          "mOnPrimary": "{{colors.on_primary.default.hex}}",

          "mSecondary": "{{colors.secondary.default.hex}}",
          "mOnSecondary": "{{colors.on_secondary.default.hex}}",

          "mTertiary": "{{colors.tertiary.default.hex}}",
          "mOnTertiary": "{{colors.on_tertiary.default.hex}}",

          "mError": "{{colors.error.default.hex}}",
          "mOnError": "{{colors.on_error.default.hex}}",

          "mSurface": "{{colors.surface.default.hex}}",
          "mOnSurface": "{{colors.on_surface.default.hex}}",

          "mSurfaceVariant": "{{colors.surface_container.default.hex}}",
          "mOnSurfaceVariant": "{{colors.on_surface_variant.default.hex}}",

          "mOutline": "{{colors.outline_variant.default.hex}}",
          "mShadow": "{{colors.shadow.default.hex}}",

          "mHover": "{{colors.tertiary.default.hex}}",
          "mOnHover": "{{colors.on_tertiary.default.hex}}"
        } */
    };
  };
}
