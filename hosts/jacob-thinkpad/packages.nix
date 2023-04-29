{ pkgs, ... }:
with pkgs; [
  ##################
  ### ESSENTIALS ###
  ##################

  ### SHELLS ###
  nushell

  ### MISSING ###
  bc
  tree

  ### APPIMAGE ###
  appimage-run

  ### CLI UTILITIES ###
  fastfetch # neofetch but made in c
  wget # simple downloader utility
  curl # network request utility
  p7zip # archive and compression tool
  git # version control
  zip # archive utility
  bat # cat with wings
  fzf # fuzzy finder
  exa # colored alternative to ls
  ripgrep # grep but rust
  sd # sed but rust
  # tealdear      # manpage summaries

  ### CODE EDITORS ###
  neovim

  ################
  ### HARDWARE ###
  ################

  ### SYSTEM DEVICES ###
  v4l-utils # proprietary media hardware and encoding
  pciutils # utilities for pci and pcie devices

  ### STORAGE DEVICE DRIVERS ###
  cryptsetup
  ntfs3g
  exfatprogs

  ### STORAGE DEVICE TOOLS ###
  gparted
  gptfdisk
  e2fsprogs

  ### HARDWARE DIAGNOSTICS ###
  cpu-x # cpu-z for linux
  btop # system process monitor
  procs # process viewer
  du-dust # du but rust
  bottom # not top
  bandwhich # network monitor

  ### VIRTUALIZATION ###
  virt-manager # gui for managing libvirt
  libguestfs # filesystem driver for vm images
]
