{ pkgs, ... }: with pkgs; [
  ##################
  ### ESSENTIALS ###
  ##################

  ### CLI UTILITIES ###
  btop  # system process monitor
  tree  # directory tree listing
  wget  # simple downloader utility
  curl  # network request utility
  git  # version control
  zip  # archive utility
  bat  # cat with wings
  fzf  # fuzzy finder
  exa  # colored alternative to ls

  ### CODE EDITORS ###
  neovim
  
  ################
  ### HARDWARE ###
  ################

  ### SYSTEM DEVICES ###
  v4l-utils  # proprietary media hardware and encoding

  ### STORAGE DEVICE DRIVERS ###
  cryptsetup
  ntfs3g
  exfatprogs

  ### HARDWARE DIAGNOSTICS ###
  wev  # input button code utility
]
