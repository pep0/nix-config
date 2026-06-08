{ username, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user.name = username;
      user.email = "baschy@msn.com";

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };

    # Sign commits with SSH using the same key that authenticates
    # pushes. Add the public key to GitHub under
    # https://github.com/settings/ssh/new with type "Signing Key" to
    # make the "Verified" badge appear on commits.
    signing = {
      signByDefault = true;
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
    };
  };

  # Delta moved out of programs.git in home-manager 25.11.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options.navigate = true;
  };

  programs.lazygit.enable = true;
}
