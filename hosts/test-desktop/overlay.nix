{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      jetbrains = prev.jetbrains // {
        idea = prev.jetbrains.idea.overrideAttrs (old: rec {
          src = prev.fetchurl {
            url = builtins.replaceStrings [ "download.jetbrains.com" ] [ "download-cdn.jetbrains.com" ] (builtins.head old.src.urls);
            sha256 = old.src.outputHash;
          };
        });
      };
    })
  ];
}
