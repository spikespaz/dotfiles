#!/bin/sh
set -e

MODULE="path:$(pwd)#homeConfigurations.jacob.activationPackage"

nix build --no-link $MODULE

$(nix path-info $MODULE)/activate
