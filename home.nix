{ config
, pkgs
, lib
, ...
}:

{
  home.username = "root";
  home.homeDirectory = "/root";

  # PROGRAMS
  programs.home-manager.enable = true;
  programs.zsh.enable = true;

  # ENV VARIABLES
  home.sessionVariables = {
    EDITOR = "micro";
  };

  # DOTFILES
  home.file = {
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
    pkgs.micro

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
