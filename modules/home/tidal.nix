{ pkgs, ... }:
let
  vim-tidal = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-tidal";
    version = "unstable-2024-10-20";
    src = pkgs.fetchFromGitHub {
      owner = "tidalcycles";
      repo = "vim-tidal";
      rev = "e440fe5bdfe07f805e21e6872099685d38e8b761";
      hash = "sha256-8gyk17YLeKpLpz3LRtxiwbpsIbZka9bb63nK5/9IUoA=";
    };
  };
in
{
  # TidalCycles: live-coding music environment. SuperCollider does the
  # synthesis; GHC + the `tidal` Haskell package interpret the patterns;
  # vim-tidal sends lines from the editor to GHCi.

  home.packages = with pkgs; [
    supercollider-with-sc3-plugins
    libsForQt5.qtwayland
    (haskellPackages.ghcWithPackages (hp: [ hp.tidal ]))
    qjackctl
  ];

  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    plugins = [
      {
        plugin = vim-tidal;
        type = "lua";
        config = ''vim.g.tidal_target = "terminal"'';
      }
    ];
  };
}
