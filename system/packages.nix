{ pkgs, ... }: with pkgs; [
  ##################
  ### ESSENTIALS ###
  ##################

  # CLI Utilities

  btop  # system process monitor
  tree  # directory tree listing
  wget  # simple downloader utility
  curl  # network request utility
  git  # version control
  zip  # archive utility
  bat  # cat with wings
  fzf  # fuzzy finder
  exa  # colored alternative to ls
  
  ################
  ### HARDWARE ###
  ################

  # System

  v4l-utils  # proprietary media hardware and encoding

  # Storage Devices

  cryptsetup
  ntfs3g
  exfatprogs
  
  ########################
  ### DEFAULT SOFTWARE ###
  ########################

  neovim  # Text Editor
]
