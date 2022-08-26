#!/bin/sh
set -e

MODULE="path:$(pwd)#"

sudo nixos-rebuild switch --flake $MODULE
