{ ... }:
{
  programs.nushell = {
    enable = true;

    # Single-letter aliases for the most-used tools. Inspired by the
    # cloudlena setup. Trade-off: very fast to type, less obvious six
    # months later when you forget what `g` means. Comments in this
    # file are the documentation.
    shellAliases = {
      a = "claude";              # AI / agentic coding
      e = "hx";                  # editor (helix)
      f = "yazi";                # file manager
      g = "lazygit";             # git browser
      l = "ls";                  # list
      m = "btop";                # system monitor
      o = "xdg-open";            # open file in default app
      t = "taskwarrior-tui";     # task manager (only works if installed)
    };

    # Nushell config is verbose; keeping it minimal here. Add to
    # extraConfig as you build out keybindings, hooks, etc.
    extraConfig = ''
      $env.config = {
        show_banner: false,
        edit_mode: vi,
      }
    '';
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableNushellIntegration = true;
  };

  # Carapace gives shell completions from a single source for many tools.
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };
}
