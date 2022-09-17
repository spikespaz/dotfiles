{ pkgs, ... }: with pkgs; [
  ##################
  ### ESSENTIALS ###
  ##################

  ### APPIMAGE ###
  appimage-run

  ### CLI UTILITIES ###
  fastfetch     # neofetch but made in c
  btop          # system process monitor
  tree          # directory tree listing
  wget          # simple downloader utility
  curl          # network request utility
  p7zip         # archive and compression tool
  git           # version control
  zip           # archive utility
  bat           # cat with wings
  fzf           # fuzzy finder
  exa           # colored alternative to ls
  ripgrep       # grep but rust
  procs         # process viewer
  sd            # sed but rust
  du-dust       # du but rust
  bottom        # not top
  bandwhich     # network monitor
  # tealdear      # manpage summaries

  ### CODE EDITORS ###
  neovim

  ################
  ### HARDWARE ###
  ################

  ### SYSTEM DEVICES ###
  v4l-utils  # proprietary media hardware and encoding
  pciutils  # utilities for pci and pcie devices

  ### STORAGE DEVICE DRIVERS ###
  cryptsetup
  ntfs3g
  exfatprogs

  ### HARDWARE DIAGNOSTICS ###
  wev  # input button code utility
]
