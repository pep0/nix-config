{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Tuna";
    userEmail = "tuna@example.com";  # change me

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
