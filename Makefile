# Makefile wrappers around `nh`. Run `make` with no args to see what's
# available. The actual commands are short enough to type by hand —
# this just documents the workflow in one place.

.PHONY: help system home update profile clean diff rollback fmt check wallpaper reseed

help:
	@echo "Targets:"
	@echo "  make system     - rebuild and switch the NixOS system"
	@echo "  make wallpaper  - re-roll the wallpaper layout and preview it"
	@echo "  make home       - rebuild and switch home-manager"
	@echo "  make profile    - install/upgrade the user profile"
	@echo "  make update     - update flake.lock (all inputs)"
	@echo "  make diff       - dry-build and show what would change"
	@echo "  make rollback   - roll system back one generation"
	@echo "  make clean      - GC: keep last 5 generations + last 14 days"
	@echo "  make fmt        - format Nix files with nixpkgs-fmt"
	@echo "  make check      - run flake check (eval all outputs)"

# The wallpaper is generated from pkgs/wallpaper/seed, which is a build
# input — a new value is the only thing that makes Nix draw a new picture.
# Re-rolling it here means every switch gets one, and the seed stays in the
# tree so a rolled-back generation still matches its own wallpaper.
system: reseed
	nh os switch .

reseed:
	shuf -i 1-999999 -n 1 > pkgs/wallpaper/seed

# Preview the next layout without switching.
wallpaper: reseed
	nix build .#wallpaper --out-link result-wallpaper
	xdg-open result-wallpaper

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
