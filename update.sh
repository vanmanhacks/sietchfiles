#!/usr/bin/env bash
# Set HOSTNAME before running, or pass via flake:
#   sudo nixos-rebuild switch --flake ".#$HOSTNAME"
HOSTNAME="${HOSTNAME:-CHANGE_ME_HOSTNAME}"

sudo nix flake update
sudo nixos-rebuild switch --flake ".#$HOSTNAME"
