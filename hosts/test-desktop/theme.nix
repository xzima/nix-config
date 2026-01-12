{ flake, inputs, hostName, perSystem, config, modulesPath, pkgs, lib, ... }: {
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

    targets.regreet.enable = false;
  };

  programs.regreet = {
    settings.GTK.application_prefer_dark_theme = true;
    # https://github.com/medanimohamedakram/Dotfiles/blob/main/greetd/regreet.toml
    extraCss = with config.programs.matugen.theme.colors; ''
      @define-color error ${error.default};
      @define-color on_error ${on_error.default};
      @define-color on_error_container ${on_error_container.default};
      @define-color on_primary ${on_primary.default};
      @define-color on_primary_container ${on_primary_container.default};
      @define-color on_surface ${on_surface.default};
      @define-color on_surface_variant ${on_surface_variant.default};
      @define-color primary ${primary.default};
      @define-color primary_container ${primary_container.default};
      @define-color shadow ${shadow.default};
      @define-color surface ${surface.default};
      @define-color surface_container ${surface_container.default};
      @define-color surface_variant ${surface_variant.default};
      @define-color tertiary ${tertiary.default};
      @define-color outline_variant ${outline_variant.default};

      * {
        all: unset;
      }

      picture {
        filter: blur(2rem);
      }

      frame.background {
        background: alpha(@surface, .92);
        color: @on_surface;
        border-radius: 4px;
        box-shadow: 0 0 12px 2px alpha(@shadow, .9);
      }

      frame.background>grid>label:first-child {
        font-size: 1.2rem;
        padding: 6px;
      }

      frame.background.top {
        font-size: 1.2rem;
        padding: 8px;
        background: @surface;
        border-radius: 0;
        border-bottom-left-radius: 24px;
        border-bottom-right-radius: 24px;
      }

      box.horizontal>button.default.suggested-action.text-button {
        background: @primary;
        color: @surface;
        padding: 12px;
        margin: 0 8px;
        border-radius: 2em;
        transition: background .3s ease-in-out;
      }

      box.horizontal>button.default.suggested-action.text-button:hover {
        background: @tertiary;
      }

      box.horizontal>button.text-button {
        background: @surface_container;
        color: @on_surface;
        padding: 12px;
        border-radius: 2em;
        transition: background .3s ease-in-out;
      }

      box.horizontal>button.text-button:hover {
        background: @tertiary;
        color: @surface;
      }

      box.bottom.vertical>box.horizontal>button.destructive-action.text-button {
        background: @surface;
        color: @error;
        padding: 12px;
        border-radius: 2em;
        border: 2px solid @error;
        transition: background .3s ease-in-out;
      }

      box.bottom.vertical>box.horizontal>button.destructive-action.text-button:hover {
        background: @error;
        color: @on_error;
      }

      combobox {
        background: @surface_container;
        color: @on_surface;
        border-radius: 12px;
        padding: 12px;
      }

      combobox:disabled {
        background-color: transparent;
        color: @on_surface;
        border-radius: 12px;
        padding: 12px;
        box-shadow: none;
      }

      combobox:hover {
        box-shadow: 0px 0px 0px 2px @tertiary;
        border-radius: 12px;
      }

      button.image-button.toggle {
        padding: 0em 0.9em;
        border-radius: 2em;
        background: @surface_container;
        transition: background .3s ease-in-out;
      }

      button.image-button.toggle:hover {
        background: @tertiary;
        color: @surface;
      }

      button.image-button.toggle:disabled {
        opacity: 0;
      }

      combobox>popover {
        background: @surface_container;
        color: @on_surface_variant;
        border-radius: 12px;
        border: 2px solid @tertiary;
        padding: 2px 12px;
      }

      combobox>popover>contents {
        padding: 2px;
      }

      modelbutton.flat {
        padding: 6px;
        margin: 2px;
      }

      modelbutton.flat:hover {
        color: @tertiary;
        font-weight: bold;
      }

      entry {
        background: @surface_container;
        border: 2px solid @primary;
        border-radius: 12px;
        padding: 12px;
      }

      entry:hover {
        border: 2px solid @tertiary;
      }

      tooltip {
        background: @surface;
        color: @on_surface;
        padding: 12px;
        border-radius: 12px;
      }
    '';
  };
}
