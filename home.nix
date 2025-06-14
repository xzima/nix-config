{ config
, pkgs
, lib
, ...
}:

{
  home.username = "root";
  home.homeDirectory = "/root";
  fonts.fontconfig.enable = true;

  # PROGRAMS
  programs.home-manager.enable = true;
  programs.command-not-found.enable = true;
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
          # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
          # Initialization code that may require console input (password prompts, [y/n]
          # confirmations, etc.) must go above this block; everything else may go below.
          # double single quotes (''$) to escape the dollar char
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
          antigen bundle debian
          antigen bundle systemd
          antigen bundle ufw
          antigen bundle lol
          antigen bundle sudo
          antigen bundle git
          antigen bundle git-flow
          antigen bundle aliases
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
          alias nix-hm-switch="home-manager switch --flake github:xzima/nix-config#pve-root --refresh"
        '';
      in
      lib.mkMerge [ beforeCfg antigenCfg afterCfg ];
  };

  # ENV VARIABLES
  home.sessionVariables = {
    EDITOR = "micro";
    MICRO_CONFIG_HOME = "~/.dotfiles/micro";
  };

  # DOTFILES
  home.file = {
    ".dotfiles/.p10k.zsh".source = home/pve-root/dotfiles/.p10k.zsh;
    ".dotfiles/micro" = {
      source = home/pve-root/dotfiles/micro;
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



  # Set zsh as default shell on activation
  home.activation.make-zsh-default-shell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # if zsh is not the current shell
    PATH="/usr/bin:/bin:$PATH"
    ZSH_PATH="/${config.home.username}/.nix-profile/bin/zsh"
    if [[ $(getent passwd ${config.home.username}) != *"$ZSH_PATH" ]]; then
      echo "setting zsh as default shell (using chsh). password might be necessay."
      if grep -q $ZSH_PATH /etc/shells; then
        echo "adding zsh to /etc/shells"
        run echo "$ZSH_PATH" | sudo tee -a /etc/shells
      fi
      echo "running chsh to make zsh the default shell"
      run chsh -s $ZSH_PATH ${config.home.username}
      echo "zsh is now set as default shell !"
    fi
  '';

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
