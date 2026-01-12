{ flake, inputs, perSystem, config, pkgs, lib, ... }: {
  programs.matugen = {
    enable = true;
    source_color = "#4caf50";
    jsonFormat = "hex";
    variant = "dark";
    type = "scheme-vibrant";
    contrast = -1;
  };

  stylix = {
    enable = true;
    polarity = "dark";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/material-darker.yaml";

    override = with config.programs.matugen.theme.colors; {
      base00 = surface.default; # Default Background
      base01 = surface_container.default; # Lighter Background (Used for status bars, line number and folding marks)
      base02 = surface_bright.default; # Selection Background
      base03 = on_surface_variant.default; # Comments, Invisibles, Line Highlighting
      base04 = on_background.default; # Dark Foreground (Used for status bars)
      base05 = on_surface.default; # Default Foreground, Caret, Delimiters, Operators
      base06 = on_surface.light; # Light Foreground (Not often used)
      base07 = surface.light; # Light Background (Not often used)
      # base08 = danger-a20; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
      # base09 = warning-a0; # Integers, Boolean, Constants, XML Attributes, Markup Link Url
      # base0A = warning-a10; # Classes, Markup Bold, Search Text Background
      # base0B = primary-a0; # Strings, Inherited Class, Markup Code, Diff Inserted
      # base0C = primary-a20; # Support, Regular Expressions, Escape Characters, Markup Quotes
      # base0D = success-a10; # Functions, Methods, Attribute IDs, Headings
      # base0E = success-a20; # Keywords, Storage, Selector, Markup Italic, Diff Changed
      # base0F = error_container.default; # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
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
    colors = with config.programs.matugen.theme.colors; rec {
      mPrimary = primary.default;
      mOnPrimary = surface.default;

      mSecondary = secondary.default;
      mOnSecondary = on_secondary.default;

      mTertiary = tertiary.default;
      mOnTertiary = on_tertiary.default;

      mError = error.default;
      mOnError = on_error.default;

      mSurface = surface.default;
      mOnSurface = on_surface.default;

      mSurfaceVariant = surface_container.default;
      mOnSurfaceVariant = on_surface.default;

      mOutline = outline_variant.default;
      mShadow = shadow.default;

      mHover = mTertiary;
      mOnHover = mOnTertiary;
    };
  };
}
