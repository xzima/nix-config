{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      jetbrains = prev.jetbrains // {
        idea-ultimate = prev.jetbrains.idea-ultimate.overrideAttrs (old: rec {
          src = prev.fetchurl {
            url = builtins.replaceStrings [ "download.jetbrains.com" ] [ "download-cdn.jetbrains.com" ] (builtins.head old.src.urls);
            sha256 = old.src.outputHash;
          };
        });
      };
    })
  ];
}
