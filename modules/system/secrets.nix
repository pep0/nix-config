{ pkgs, inputs, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  # sops-nix unlocks an age-encrypted YAML/JSON file at activation time
  # and exposes individual values as files under /run/secrets, scoped to
  # whichever process needs them. See SECRETS.md for the bootstrap.
  #
  # No secrets are declared yet — adding `sops.secrets.<name> = {};` and
  # creating `secrets/secrets.yaml` with `sops` is what wires real values
  # into the system.

  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = false;  # bootstrap manually so the same key isn't regenerated on every host
  };

  # Make sops + age available so you can edit secrets on this machine.
  environment.systemPackages = with pkgs; [
    sops
    age
    ssh-to-age
  ];
}
