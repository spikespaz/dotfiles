{ pkgs, config, ... }: {
  # NOTE:
  # You're supposed to add users to the `adbusers` group for
  # these rules to work, but it works for me regardless.
  # Perhaps these rules work for users in `wheel`?
  # <https://github.com/NixOS/nixpkgs/blob/nixos-23.05/nixos/modules/programs/adb.nix>
  programs.adb.enable = true;

  # Packages which are appropriate for a typical Linux system.
  # There should be **no GUI programs** in this list.
  environment.systemPackages = with pkgs; [
    ##################
    ### ESSENTIALS ###
    ##################

    ### MISSING ###
    bc
    tree
    unzip

    ### CLI UTILITIES ###
    fastfetch # neofetch but made in c
    wget # simple downloader utility
    curl # network request utility
    p7zip # archive and compression tool
    git # version control
    zip # archive utility
    bat # cat with wings
    fzf # fuzzy finder
    eza # colored alternative to ls
    ripgrep # grep but rust
    sd # sed but rust
    # tealdear      # manpage summaries

    ### CODE EDITORS ###
    neovim

    ################
    ### HARDWARE ###
    ################

    ### SYSTEM DEVICES ###
    config.boot.kernelPackages.cpupower
    v4l-utils # proprietary media hardware and encoding
    pciutils # utilities for pci and pcie devices

    ### GRAPHICS TOOLS ###
    vulkan-tools

    ### STORAGE DEVICE DRIVERS ###
    cryptsetup
    ntfs3g
    exfatprogs

    ### STORAGE DEVICE TOOLS ###
    gptfdisk
    e2fsprogs

    ### HARDWARE DIAGNOSTICS ###
    smartmontools # for drive SMART status
    btop # system process monitor
    bottom # not top
    procs # process viewer
    du-dust # du but rust
    bandwhich # network monitor

    ### VIRTUALIZATION ###
    libguestfs # filesystem driver for vm images
  ];

  # # gui tool for processor management
  # programs.corectrl.enable = true;
  # # sets the overdrive bit in amdgpu.ppfeaturemask
  # programs.corectrl.gpuOverclock.enable = true;
}
