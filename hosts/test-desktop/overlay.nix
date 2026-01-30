{
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      /*
      fix freeze 'what's new..' and markdown preview
      https://www.reddit.com/r/IntelliJIDEA/comments/1bvm4y0/intellij_crashing_after_last_update_when_trying/
      https://github.com/NixOS/nixpkgs/issues/143122
      https://youtrack.jetbrains.com/articles/JBR-A-11
      Edit Custom Properties...
      #ide.browser.jcef.gpu.disable=true
      #ide.browser.jcef.sandbox.enable=false
      ide.browser.jcef.enabled=false
      */
      jetbrains =
        prev.jetbrains
        // {
          idea = prev.jetbrains.idea.overrideAttrs (old: rec {
            src = prev.fetchurl {
              url = builtins.replaceStrings ["download.jetbrains.com"] ["download-cdn.jetbrains.com"] (builtins.head old.src.urls);
              sha256 = old.src.outputHash;
            };
          });
        };
    })
  ];
}
