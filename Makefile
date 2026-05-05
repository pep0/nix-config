# Makefile wrappers around `nh`. Run `make` with no args to see what's
# available. The actual commands are short enough to type by hand —
# this just documents the workflow in one place.

.PHONY: help system home update profile clean diff rollback fmt check

help:
	@echo "Targets:"
	@echo "  make system     - rebuild and switch the NixOS system"
	@echo "  make home       - rebuild and switch home-manager"
	@echo "  make profile    - install/upgrade the user profile"
	@echo "  make update     - update flake.lock (all inputs)"
	@echo "  make diff       - dry-build and show what would change"
	@echo "  make rollback   - roll system back one generation"
	@echo "  make clean      - GC: keep last 5 generations + last 14 days"
	@echo "  make fmt        - format Nix files with nixfmt"
	@echo "  make check      - run flake check (eval all outputs)"

system:
	nh os switch .

home:
	nh home switch .

# Install the user profile the first time, then `nix profile upgrade`
# on subsequent runs. The trailing `|| ...` lets a fresh install work
# even though `upgrade` would fail.
profile:
	nix profile upgrade user-profile || nix profile install .#profile

update:
	nix flake update

diff:
	nh os build . --dry

rollback:
	sudo nixos-rebuild switch --rollback

clean:
	nh clean all --keep-since 14d --keep 5

fmt:
	nix fmt

check:
	nix flake check
