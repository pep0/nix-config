# Secrets (sops-nix)

Encrypted, declarative secrets. Values live in `secrets/secrets.yaml`
encrypted with an age key. The system decrypts them at activation and
exposes each as a file under `/run/secrets/<name>`.

## Bootstrap a fresh machine

1. **Generate an age key** for this host. Stash the *private* key on
   the machine, share only the *public* key:
   ```
   sudo mkdir -p /var/lib/sops-nix
   sudo age-keygen -o /var/lib/sops-nix/key.txt
   sudo chmod 600 /var/lib/sops-nix/key.txt
   ```
   The public key (line starting with `# public key: age1...`) is what
   you publish.

2. **Update `.sops.yaml`** at the repo root: replace the
   `age1placeholder...` anchor with the public key from step 1, then
   commit. Anyone with the matching private key can now decrypt.

3. **Create your encrypted file**:
   ```
   sops secrets/secrets.yaml
   ```
   `sops` opens `$EDITOR` on a decrypted view; on save it re-encrypts
   with the keys listed in `.sops.yaml`. Commit the encrypted file —
   it's safe in source control.

4. **Wire a secret into the system** in any module:
   ```nix
   sops.defaultSopsFile = ../../secrets/secrets.yaml;
   sops.secrets."wifi/home_psk" = { };
   networking.wireless.networks."MyWifi".pskFile =
     config.sops.secrets."wifi/home_psk".path;
   ```

5. **Rebuild** with `make system`. The secret materializes at
   `/run/secrets/wifi/home_psk` only after the unit that needs it
   starts.

## Re-keying / adding a second machine

- Each machine has its own keypair. Add the new public key as another
  anchor in `.sops.yaml`, then run `sops updatekeys secrets/secrets.yaml`
  to re-encrypt the existing file with both recipients.

## SSH-key shortcut

If you already have an `ed25519` SSH host key, you can derive an age
key from it instead of generating a new one:
```
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
```
Use the result as the public key in `.sops.yaml`. Decryption uses
`/etc/ssh/ssh_host_ed25519_key` automatically — no separate `key.txt`
needed (set `sops.age.sshKeyPaths` instead of `sops.age.keyFile`).

## Anti-patterns

- Don't commit `/var/lib/sops-nix/key.txt`. Ever.
- Don't put plaintext secrets in `secrets/` — sops won't re-encrypt
  them automatically; the file just gets committed in the clear.
- Don't share the private key across machines if you can avoid it. The
  multi-recipient pattern above is cheap.
