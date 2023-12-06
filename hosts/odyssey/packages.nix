{ pkgs, ... }: { environment.systemPackages = with pkgs; [ amdctl ]; }
