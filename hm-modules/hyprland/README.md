So basically I've made a miniature document model for the configuration format.
I want to refractor it<sup>[1]</sup> to pass around functions some more,
but the idea is that when vaxry changes the syntax, you can add a new type of node<sup>[2]</sup>,
change how it is rendered to text<sup>[3]</sup>, change pre- and post-processing such as sorting,
indents, and line-breaks via predicate functions<sup>[4],[5]</sup>, and use submodule option
types to sugar<sup>[6][7]</sup> the configuration with Nix syntax.

For example, my personal config: <https://github.com/spikespaz/dotfiles/tree/master/users/jacob/desktops/hyprland>

[1]: <https://github.com/spikespaz/dotfiles/blob/master/hm-modules/hyprland/configFormat.nix#L62>
[2]: <https://github.com/spikespaz/dotfiles/blob/master/hm-modules/hyprland/configFormat.nix#L46>
[3]: <https://github.com/spikespaz/dotfiles/blob/master/hm-modules/hyprland/configFormat.nix#L130>
[4]: <https://github.com/spikespaz/dotfiles/blob/master/hm-modules/hyprland/configFormat.nix#L6>
[5]: <https://github.com/spikespaz/dotfiles/blob/master/hm-modules/hyprland/config.nix#L133>
[6]: <https://github.com/spikespaz/dotfiles/blob/master/hm-modules/hyprland/keybinds.nix#L89>
[7]: <https://github.com/spikespaz/dotfiles/blob/master/hm-modules/hyprland/rules.nix#L94>
