{ flake, inputs, perSystem, config, pkgs, lib, ... }:
{

  imports = [
    flake.homeModules.shell
  ];

  home.stateVersion = "25.05";

  home.username = "root";
  home.homeDirectory = "/root";

  programs.home-manager.enable = true;

  custom.shell = {
    antigenBundles = [ "debian" ];
  };

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
}
