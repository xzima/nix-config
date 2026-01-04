# run `nix develop .#idea`
{ pkgs, perSystem, ... }:
(pkgs.buildFHSEnv {
  name = "idea-fhs";
  # Packages available to the wrapped application in the FHS environment
  targetPkgs = pkgs: [
    # Add necessary dependencies here if the IDE or your project needs them
    #    ((pkgs.jetbrains.idea.overrideAttrs
    #      (old: rec {
    #        src = builtins.fetchurl {
    #          url = builtins.replaceStrings [ "download.jetbrains.com" ] [ "download-cdn.jetbrains.com" ] (builtins.head old.src.urls);
    #          sha256 = old.src.outputHash;
    #        };
    #      })).override { forceWayland = true; })
  ];
  # The actual application packages to include and run
  multiPkgs = pkgs: [
    ((pkgs.jetbrains.idea.overrideAttrs
      (old: rec {
        src = builtins.fetchurl {
          url = builtins.replaceStrings [ "download.jetbrains.com" ] [ "download-cdn.jetbrains.com" ] (builtins.head old.src.urls);
          sha256 = old.src.outputHash;
        };
      })).override { forceWayland = true; })
    # You might need to add other tools your project uses, e.g.,
    # pkgs.jdk # The JetBrains bundled JDK is usually sufficient
    # pkgs.gradle
    # pkgs.python3
    # pkgs.node J
  ] ++ pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs pkgs;
  # The command to run when entering the FHS environment
  runScript = "idea $*";
}).env
