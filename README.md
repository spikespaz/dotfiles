# BirdOS

Welcome, this repository houses my personal configuration files
for my computers running [NixOS].

There are may modules and packages that some people may find useful to
utilize in their own [NixOS] or [Home Manager] environments.

# Usage

To use components from my flake in your own configurations,
add it as an input in your `flake.nix`:

```nix
{
  # Assumes you already have `nixpkgs` as an input.
  inputs.birdos.url = "github:spikespaz/dotfiles/master";
  inputs.birdos.inputs.nixpkgs.follows = "nixpkgs";
}
```

> **Q:** What does the second line with `follows` accomplish?
>
> **A:** The first time something from a flake is built (or some other command is run),
> the inputs are locked in a file named `flake.lock`.
> This is a JSON file that contains a long registry of inputs--
> as well as the inputs of your inputs--
> and each entry is associated with a Git hash which determines what revision
> or "version" of that input your flake will use.
>
> Now, when you use something like `input.A.inputs.B.follows = "C"`,
> this allows you to override input `B` of flake `A` to instead use
> another input from your flake, `C`, where `C` is an attribute name from your
> own `inputs`, which is locked in your own `flake.lock`.
>
> In the code block above, this mechanism demonstrates the ability to override
> the `flake.lock` which is cloned from this repository and instead replace the
> [Nixpkgs] input to use the revision that you have locked instead. This means you don't
> have to wait on me to run `nix flake update` or `nix flake lock --update-input nixpkgs`
> before you can compile `birdos` packages with the latest dependencies from [Nixpkgs].

---

# Library

If you want to use the extended `lib` provided by this flake, you can either
use `inputs.birdos.lib` (assuming `birdos` is what you named
the input), or you can extend [Nixpkgs]' lib with `lib.extend`.

For example, in a `let` block before your flake's output attributes:

```nix
let
  lib = nixpkgs.lib.extend (import "${inputs.birdos}/lib");
  tree = lib.birdos.mkFlakeTree ./.; # example usage of lib
  # ...
in
```

Some `lib` functions added by this flake are top-level, but some
that are not generally useful to the bulk of configuration are hidden
behind the `birdos` attribute (such as flake utilities).

You can learn what is inherited at the top-level `lib`
by printing out `lib.birdos.prelude`.

---

# Packages

For packages, you have two options. Either use the flake's `packages` output
or the `overlays` output.

> You might want to use the `default` overlay if you use multiple packages
> from this flake, or if you want to compile them with dependencies provided by your
> locked revision of [Nixpkgs].
>
> Do note however that if you do *not* use the `default` overlay,
> packages are (nearly) guaranteed to build; if you do use the
> overlay, Nix will try to build packages using newer dependencies from
> [Nixpkgs] instead of using the ones decreed by this flake's `flake.lock`,
> which *might* result in build errors.
>
> In the event that you are using the `default` overlay and it causes build errors,
> please consider using the method shown in the first example below for that
> specific package.
>
> This mechanism accomplishes much the same goal as using `inputs.follows`
> where you list this flake as an input, but the two approaches are not identical.

Make sure you have added `inputs` to `specialArgs` in the attribute set passed
to `lib.nixos.nixosSystem`, or `extraSpecialArgs` for `home-manager.lib.homeManagerConfiguration`:

```nix
{
  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      # ...
    in {
      homeConfigurations = {
        jacob = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit nixpkgs inputs; };
        };
      };
      # ...
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
use something similar to this when importing [Nixpkgs]:

```nix
{
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  home-manager.url = "github:nix-community/home-manager";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.birdos.url = "github:spikespaz/dotfiles";
  inputs.birdos.inputs.nixpkgs.follows = "nixpkgs";

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
            # Last checked, Nixpkgs applies the unfree predicate before merging
            # overlays, so packages from overlays with unfree licenses will not
            # care about the policy set by your Nixpkgs options.
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

---

# Building Configurations

This section is mostly for my personal reference,
but it is also good for the newbies so I will make it extensive.
Some of these are untested because I am writing them down when I feel clever,
if any are wrong, please open an issue.

All commands assume that you are at the root of the cloned repository.

## Build activation packages

[NixOS] system package for the current hostname:

```
nix build "path:.#nixosConfigurations.$(hostname).config.system.build.toplevel"
```

[Home Manager] package for the current user:

```
nix build "path:.#homeConfigurations.$USER.activationPackage"
```

## Install a system configuration

Prepare the disk for installation.

1. Partition the disk.
2. Format the disk partitions.
3. Mount partitions relative to `/mnt`. Ensure that volumes are mounted
   with the same options you want to use even after your installation.

Install the configuration by hostname.

Usage of `--no-root-password` assumes
that you are using a configuration that specifies
`user.users.root.hashedPassword = "!"`, which effectively disables root login.
Do not use this option if you have no users configured.

> The following command tells nix to run four jobs at a time,
> each job with access to a quarter of your CPU cores.
> For example, with a 6-core, 12-thread CPU, each job would be allocated 3 threads,
> and with an 8-core, 16-thread CPU each job gets 4 threads.

```sh
nixos-install --flake "path:.#$(hostname)" --no-root-password --cores "$(($(nproc)/4))" -j 4
```

### Activate a user configuration

This requires that the user in question is logged in and has an active shell.

```sh
home-manager switch --flake "path:.#$USER"
```

Or perhaps more explicitly,

```sh
nix --extra-experimental-features nix-command --extra-experimental-features flakes \
run 'github:nix-community/home-manager/master' -- switch --flake "path:.#$USER"
```

### Activate a system configuration

This assumes that the hostname of the system matches with the name of the system
configuration that you would like to switch to.

```sh
nixos-rebuild switch --flake "path:.#$(hostname)"
```

---

# Troubleshooting

If you have a problem with any of the modules or packages provided by this
flake, **please** open an issue and let me know so that others can benefit.

As for the `hosts` and `users` configuration, no support will be provided if
you copy/adapt code from these directories. If you use them as an example or
basis for your own setup, and need help understanding something, don't
hesitate to ask for my help, but if you attempt to use a large section of
code without studying it, just know that I don't fish for charity.

---

# References

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

If you came here on your own, and would like to find help with Nix or [NixOS],
I encourage you to join [this small Discord server](https://discord.gg/8ydgceUJDm), mostly led by [@NobbZ].

---

[NixOS]: https://nixos.org/
[Nixpkgs]: https://github.com/nixos/nixpkgs
[Home Manager]: https://github.com/nix-community/home-manager

[@NobbZ]: https://github.com/NobbZ/
[@tejing1]: https://github.com/tejing1
[@viperML]: https://github.com/viperml
[@fufexan]: github.com/fufexan
