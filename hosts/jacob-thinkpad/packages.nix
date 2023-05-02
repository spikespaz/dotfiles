{ pkgs, ... }: {
  # NO GUI PACKAGES
  environment.systemPackages = with pkgs; [
    ##################
    ### ESSENTIALS ###
    ##################

    ### MISSING ###
    bc
    tree

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
    gptfdisk
    e2fsprogs

    ### HARDWARE DIAGNOSTICS ###
    btop # system process monitor
    bottom # not top
    procs # process viewer
    du-dust # du but rust
    bandwhich # network monitor

    ### VIRTUALIZATION ###
    libguestfs # filesystem driver for vm images
  ];
}
