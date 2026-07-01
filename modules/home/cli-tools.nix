{ pkgs, ... }:
{
  # CLI tools installed into the home-manager profile so they show up
  # on every `make system` rebuild. `programs.<name>.enable` is used
  # where home-manager has a module — that gets stylix theming and
  # declarative config; plain `home.packages` for the rest.
  #
  # The `profile/` flake output mirrors this list for non-NixOS hosts
  # (`nix profile install .#profile`); the two lists are kept in sync
  # by hand. If you only run NixOS, you can ignore `make profile`.

  # Helix's native "dracula" theme is a hand-tuned mapping (e.g. strings
  # yellow, functions green) that stylix's generic base16 template doesn't
  # reproduce, so it opts out of stylix theming here while everything else
  # stays on stylix.
  stylix.targets.helix.enable = false;

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "dracula";
      editor = {
        bufferline = "multiple";
        cursorline = true;
        line-number = "relative";
        trim-trailing-whitespace = true;
        statusline.left = [ "mode" "spinner" "version-control" "file-name" ];
        file-picker.hidden = false;
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
          auto-signature-help = true;
        };
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
      keys = {
        normal = {
          "A-x" = "extend_to_line_bounds";
          X = [ "extend_line_up" "extend_to_line_bounds" ];
          H = "goto_previous_buffer";
          L = "goto_next_buffer";
          "A-w" = ":buffer-close";
          "A-/" = "repeat_last_motion";
        };
        insert.j.k = "normal_mode";
        select = {
          "A-x" = "extend_to_line_bounds";
          X = [ "extend_line_up" "extend_to_line_bounds" ];
        };
      };
    };
  };
  programs.yazi = {
    enable = true;
    # 26.05 changed the default from "yy" to "y"; pin the old name.
    shellWrapperName = "yy";
  };
  programs.btop.enable = true;
  programs.bat.enable = true;
  programs.fastfetch.enable = true;

  home.packages = with pkgs; [
    # search / inspection
    ripgrep
    fd
    jq
    ncdu
    nvtopPackages.full

    # build / archive
    gnumake
    zip
    unzip

    # nix dev
    nixpkgs-fmt
    nil                    # nix LSP

    # ai / dev shells
    claude-code
    devenv
  ];
}
