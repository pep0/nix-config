{ ... }:
{
  programs.git = {
    enable = true;
    userName = "pep0";
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
