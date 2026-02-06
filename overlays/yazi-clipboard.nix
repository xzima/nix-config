final: prev: {
  yaziPlugins =
    prev.yaziPlugins
    // {
      clipboard = final.yaziPlugins.mkYaziPlugin {
        pname = "clipboard.yazi";
        version = "master.25-09-2025";

        src = final.fetchFromGitHub {
          owner = "XYenon";
          repo = "clipboard.yazi";
          rev = "9089f90e48b90244355e943e879be8ab86f921c9";
          hash = "sha256-5XGSpBObCRjmf0UwwFcsG3ekoNNBMWyZerqTAo5Ak+A=";
          # hash = final.lib.fakeHash;
        };

        meta = {
          description = "Clipboard sync plugin for Yazi that copies yanked file paths to the system clipboard";
          homepage = "https://github.com/XYenon/clipboard.yazi";
          license = final.lib.licenses.agpl3Only;
          maintainers = with final.lib.maintainers; [xyenon];
        };
      };
    };
}
