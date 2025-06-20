{ config, pkgs, lib, ... }:
let
  cfg = config.programs.myZsh;
  defaultAntigenBundles = [
    "systemd"
    "ufw"
    "lol"
    "sudo"
    "git"
    "history"
    "colored-man-pages"
    "command-not-found"
    "compleat"
    "copypath"
    "cp"
    "dircycle"
    "encode64"
    "extract"
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-history-substring-search"
    "zsh-users/zsh-autosuggestions"
  ];
in
{
  options.programs.myZsh = {
    fix-hostname = lib.mkEnableOption "add HOST env variable fix for lxc containers";
    antigenBundles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "A list of antigen plugin bundles, which should be enabled";
    };
  };
  config = {
    fonts.fontconfig.enable = true;

    # PROGRAMS
    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history.size = 10000;
      oh-my-zsh.enable = true;
      initContent =
        let
          beforeCfg = lib.mkOrder 500 ''
            # double single quotes (''$) to escape the dollar char
            ${lib.mkIf cfg.fix-hostname "export HOST=\${HOST:-$(hostname)}"}
            # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
            # Initialization code that may require console input (password prompts, [y/n]
            # confirmations, etc.) must go above this block; everything else may go below.
            if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
              source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi
          '';
          antigenCfg = lib.mkOrder 750 ''
            # Fix the slowness of zsh prompt, by removing the git status stuff that slows it down...
            # https://gist.github.com/msabramo/2355834
            function git_prompt_info() {
                ref=$(git symbolic-ref HEAD 2> /dev/null) || return
                echo "$ZSH_THEME_GIT_PROMPT_PREFIX''${ref#refs/heads/}''${ZSH_THEME_GIT_PROMPT_CLEAN}''${ZSH_THEME_GIT_PROMPT_SUFFIX}"
            }
            # Enable antigen
            source ${pkgs.antigen}/share/antigen/antigen.zsh
            # Configure oh-my-zsh
            antigen use oh-my-zsh
            # Load bundles https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
            ${lib.concatLines (builtins.map (x: "antigen bundle ${x}") (defaultAntigenBundles ++ cfg.antigenBundles))}
            antigen bundle debian
            antigen bundle systemd
            antigen bundle ufw
            antigen bundle lol
            antigen bundle sudo
            antigen bundle git
            antigen bundle git-flow
            antigen bundle history
            antigen bundle colored-man-pages
            antigen bundle command-not-found
            antigen bundle compleat
            antigen bundle copypath
            antigen bundle cp
            antigen bundle dircycle
            antigen bundle encode64
            antigen bundle extract
            antigen bundle zsh-users/zsh-syntax-highlighting
            antigen bundle zsh-users/zsh-history-substring-search
            antigen bundle zsh-users/zsh-autosuggestions
            # Load the theme
            antigen theme romkatv/powerlevel10k
            # Tell Antigen that you're done
            antigen apply
          '';
          afterCfg = lib.mkOrder 1500 ''
            # Configure theme
            source ~/.dotfiles/.p10k.zsh
            # Aliases
            alias c="clear"
            alias ed="$EDITOR"
            alias vw="bat"
            alias my-ip="curl checkip.amazonaws.com"
            function nix-rb() {
              source /etc/os-release
              if [ "nixos" = "$ID" ]; then
                nixos-rebuild switch --flake github:xzima/nix-config --refresh
              else
                home-manager switch --flake github:xzima/nix-config#$(hostname) --refresh
              fi
              rm -f ~/.zshrc.zwc
            }
            function nix-gc() {
              nix store gc --debug
              nix-collect-garbage --delete-old
            }
          '';
        in
        lib.mkMerge [ beforeCfg antigenCfg afterCfg ];
    };

    # ENV VARIABLES
    home.sessionVariables = {
      EDITOR = "micro";
      MICRO_CONFIG_HOME = "${config.home.homeDirectory}/.dotfiles/micro";
    };

    # DOTFILES
    home.file = {
      ".dotfiles/.p10k.zsh".source = ../dotfiles/.p10k.zsh;
      ".dotfiles/micro" = {
        source = ../dotfiles/micro;
        recursive = true;
      };
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    home.packages = [
      pkgs.git
      pkgs.micro # replace nano
      pkgs.bat # replace cat
      pkgs.ripgrep # replace grep
      pkgs.antigen # zsh plugins
      pkgs.meslo-lgs-nf # zsh theme font

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];
  };
}
