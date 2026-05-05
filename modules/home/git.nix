{ ... }:
{
  programs.git = {
    enable = true;
    userName = "pep0";
    userEmail = "pep0@example.com";

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
