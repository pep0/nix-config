{ username, ... }:
{
  programs.git = {
    enable = true;
    userName = username;
    userEmail = "baschy@msn.com";

    delta = {
      enable = true;
      options.navigate = true;
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

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  programs.lazygit.enable = true;
}
