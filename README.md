# Jacob's NixOS Dotfiles

Welcome. This repository houses my personal configuration files for my computers running NixOS.

If you are interested in my configurations for certain programs, check out the `users` directory.

## Troubleshooting

If there are any issues with programs, search the codebase for the name of the program and look for comments. I add notes whenever I see something funny that needs to be tweaked.

## References

It would have been an impossibility to set everything up without the support of several people. I thank them for both their conversational guidance and graciously sharing their personal configurations for me to read and learn from.

- <https://github.com/fufexan/dotfiles>
- <https://github.com/NobbZ/nixos-config>
- <https://github.com/viperML/dotfiles>
- <https://github.com/IceDBorn/IceDOS>
- <https://github.com/yrashk/nix-home>
- <https://github.com/MatthiasBenaets/nixos-config>
- <https://github.com/MatthewCroughan/nixcfg>
- <https://git.gaze.systems/dusk/ark>

If you came here on your own, and would like to find help with Nix or NixOS, I encourage you to join [this small Discord server](https://discord.gg/8ydgceUJDm).


---

# Jacob's `dotpkgs`

### Modules & Packages

- [**fastfetch**](https://github.com/LinusDierheimer/fastfetch) - A faster alternative to Neofetch, written in C.
- [**idlehack**](https://github.com/loops/idlehack/blob/master/idlehack.c#L38-L79) - Intercepts DBus inhibit signals from media players, and forwards them (smartly) to *systemd*.
- [**plymouth-themes**](https://github.com/adi1090x/plymouth-themes) - Themes for Plymouth from @adi1090x, ported from Android boot animations.
- **prtsc** - Package containing a simple Perl script wrapping [`grim`](https://sr.ht/~emersion/grim/) and [`slurp`](https://github.com/emersion/slurp), providing screenshot functionality on Wayland.
- **randbg** - Simple module for Home Manager that sets up a *systemd* service which changes the background randomly, based on your configured parameters.
- **uniform-theme** - Home Manager module that provides ergonomic options to order the setup of uniform GTK and Qt themes, as well as cursors and icons.
- **zsh-uncruft** - Home Manager module that provides options for writing ZSH's dotfiles, intended to replace the default module in Home Manager for the purposes of reducing bloat.
- [**auto-cpufreq**](https://github.com/AdnanHodzic/auto-cpufreq) - Module for smart CPU frequency and governor daemon.
