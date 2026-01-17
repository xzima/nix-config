final: prev: {
  jetbrains =
    prev.jetbrains
    // {
      idea-fix = let
        ideaOverAttr = final.jetbrains.idea.overrideAttrs (old: {
          src = builtins.fetchurl {
            url = builtins.replaceStrings ["download.jetbrains.com"] ["download-cdn.jetbrains.com"] (
              builtins.head old.src.urls
            );
            sha256 = old.src.outputHash;
          };
        });
        ideaOver = ideaOverAttr.override {
          forceWayland = true;
        };
      in
        final.buildFHSEnv {
          name = "idea";
          targetPkgs = pkgs: [
            ideaOver
          ];
          multiPkgs = pkgs: pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs pkgs;
          runScript = "idea $*";
          extraInstallCommands = ''
            ln -s "${ideaOver}/share" $out
          '';
        };
    };
}
