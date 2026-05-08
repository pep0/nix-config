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

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  programs.lazygit.enable = true;
}
