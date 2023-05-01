# BirdOS

Welcome. This repository houses my personal configuration files
for my computers running NixOS.

There are also may modules and packages that some people may find useful to
utilize in their own NixOS or Home Manager environments.

## Usage

To use modules from my flake in your own configurations,
add it as an input in `flake.nix`:

```nix
inputs.birdos.url = "github:spikespaz/dotfiles";
inputs.birdos.nixpkgs.follows = "nixpkgs";
```

### Library

If you want to use the extended `lib` provided by this flake, you can either
use the `inputs.birdos.lib` attribute (assuming `birdos` is what you named
the input), or you can extend [nixpkgs]' lib with `lib.extend`.

For example, in a `let` block before your flake's output attributes:

```nix
let
  lib = nixpkgs.lib.extend (import "${inputs.birdos}/lib");
  tree = lib.birdos.mkFlakeTree ./.; # for example
  # ...
in
```

Some `lib` functions added by this flake are top-level, but some
that are not generally useful to the bulk of configuration are hidden
behind the `birdos` attribute (such as flake utilities).

You can learn what is inherited at the top-level `lib`
by printing out `lib.birdos.prelude`.

### Packages

For packages, you have two options. Either use the flake's `packages` output
or the `overlays` output.

Make sure you have added `inputs` to `specialArgs` or `extraSpecialArgs`
in your `lib.nixos.nixosSystem` or `home-manager.lib.nixosConfiguration`:

```nix
outputs = inputs@{ nixpkgs, home-manager, ... }:
  let
  # ...
  in {
    homeConfigurations = {
      jacob = home-manager.lib.homeManagerConfiguration = {
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = { inherit nixpkgs inputs; };
      };
    };
    # ...
  }
```

Then you can use it in modules which take `inputs` as an attribute argument,
for example to install `fastfetch` to your user session:

```nix
{ pkgs, lib, inputs, ... }: {
  home.packages = [
    inputs.birdos.packages.${pkgs.system}.fastfetch
    # ...
  ];
  # ...
}
```

For those of you who like to use overlays,
use something similar to this when importing [nixpkgs]:

```nix
{
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  home-manager.url = "github:nix-community/home-manager";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.birdos.url = "github:spikespaz/dotfiles";
  inputs.birdos.nixpkgs.follows = "nixpkgs";

  outputs = inputs@{ nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" "aarch64-linux" "arm64-linux" ];

      pkgsFor = builtins.genAttrs systems (system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            # All packages from BirdOS dotfiles.
            inputs.birdos.overlays.default
            # If you use packages from this flake that have an unfree license,
            # you need to include this if `nixpkgs.config.allowUnfree`
            # and `nixpkgs.config.allowUnfreePredicate` don't work for you.
            # Last checked, nixpkgs applies the unfree predicate before merging
            # overlays, so packages from overlays with unfree licenses will not
            # care about the policy set by your nixpkgs options.
            inputs.birdos.overlays.allowUnfree
            # The overlay for OracleJDK 8 to get around Oracle's sign-in page.
            inputs.birdos.overlays.oraclejdk
          ];
        });
    in {
      packages = lib.genAttrs systems (system:
        let pkgs = pkgsFor.${system};
        in {
          # ...
        });

      nixosConfigurations = {
        # ...
      };

      homeConfigurations = {
        # ...
      };
    };
}
```

Then you can use the packages from this flake directly from the `pkgs`
attribute argument to your modules.
For example, installing `fastfetch` as a system package:

```nix
{ pkgs, lib, ... }: {
  environment.systemPackages = [
    pkgs.fastfetch
    # ...
  ];
  # ...
}
```

## Troubleshooting

If you have a problem with any of the modules or packages provided by this
flake, **please** open an issue and let me know so that others can benefit.

As for the `hosts` and `users` configuration, no support will be provided if
you copy/adapt code from these directories. If you use them as an example or
basis for your own setup, and need help understanding something, don't
hesitate to ask for my help, but if you attempt to use a large section of
code without studying it, just know that I don't fish for charity.

## References

It would have been an impossibility to set everything and learn how this crazy
software works  up without the support of many people.

I would like to specifically thank [@NobbZ] for his continued
critique, and for fielding may of the questions asked by new users
in the community.

Others noteworthy fellows would be [@tejing1], [@viperML], [@fufexan].

I thank them for both their conversational guidance and graciously sharing their
personal configurations for me to read and learn from.

- <https://github.com/NobbZ/nixos-config>
- <https://github.com/tejing1/nixos-config>
- <https://github.com/fufexan/dotfiles>
- <https://github.com/viperML/dotfiles>
- <https://github.com/hlissner/dotfiles>

If you came here on your own, and would like to find help with Nix or NixOS, I encourage you to join [this small Discord server](https://discord.gg/8ydgceUJDm), led by [@Nobbz].

---

[nixpkgs]: https://github.com/nixos/nixpkgs

[@NobbZ]: https://github.com/NobbZ/
[@tejing1]: https://github.com/tejing1
[@viperML]: https://github.com/viperml
[@fufexan]: github.com/fufexan
