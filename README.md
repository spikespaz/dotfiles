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

# Modules

This flake has several modules for both [Home Manager] and [NixOS] that you will probably find useful.
My two favorites are the
[*swayidle* module](https://github.com/spikespaz/dotfiles/blob/master/hm-modules/swayidle.nix)
([example config](https://github.com/spikespaz/dotfiles/blob/master/users/jacob/desktops/wayland/timeouts.nix)),
and the
[Hyprland module](https://github.com/spikespaz/dotfiles/tree/master/hm-modules/hyprland)
([example config](https://github.com/spikespaz/dotfiles/tree/master/users/jacob/desktops/hyprland)).

> ### List available modules
>
> To see all the modules made available, run the command(s):
>
> ```sh
> nix eval 'github:spikespaz/dotfiles#nixosModules' --apply 'builtins.attrNames'
> # and
> nix eval 'github:spikespaz/dotfiles#homeManagerModules' --apply 'builtins.attrNames'
> ```

Assuming that you have this flake added as an input to your own (described above under [Usage](#usage)):
1. Make sure your flake's `inputs` are passed to `specialArgs` or `extraSpecialArgs`
   wherever you call `nixpkgs.lib.nixosSystem` or `home-manager.lib.homeManagerConfiguration`.
1. Create a new `*.nix` file in your flake, wherever you like.
2. Make sure that the file you created is imported somewhere.
   - In the `modules` attribute of a call to `nixpkgs.lib.nixosSystem`,
   - In the `modules` attribute of a call to `home-manager.lib.homeManagerConfiguration`,
   - In the `imports` list of another module.
3. Make sure that the file is a lambda including `inputs` as an argument.
4. Add the module you want to the `imports` list of the file you created.
   - *This is a recommendation. There are other ways, detailed later.*
5. Set the options you want from the module you used.

## Example usage of modules

You may organize your flake however you want.
Following is a minimal example with that satisfies my personal preferences.

Here is an example of a directory structure where certain files use specific modules.
Not every file shown in the tree is relevant to the example,
but each is presented with the intent to represent an average setup.

```ruby
.
├── flake.lock
├── flake.nix
├── hosts
│   └── intrepid
│       ├── bootloader.nix
│       ├── configuration.nix
│       ├── filesystems.nix
│       └── powerplan.nix # Imports the `amdctl` module.
└── users
    └── jacob
        ├── desktops
        │   ├── hyprland
        │   │   ├── default.nix # Imports the `hyprland` module...
        │   │   ├── config.nix # which is used here,
        │   │   └── windowrules.nix # and here.
        │   └── wayland
        │       ├── default.nix # Imports the `timeous.nix` file.
        │       └── timeouts.nix # Imports the `swayidle` module.
        └── profile.nix
```

### Contents of `flake.nix`:

This is a larger example that shows usage of both [NixOS] and [Home Manager] modules.
It also shows several different ways of using the `imports` attribute
that are specific to the circumstance.

> I think that it is best-practice to keep imports of modules to the scopes
> in which they are used. In the long run, if a file is included in your module
> tree somewhere, the options defined by it are made globally available.
> Regardless of this fact, keeping imports to narrow scopes
> allows for greater portability.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    birdos.url = "github:spikespaz/dotfiles";
    birdos.inputs.nixpkgs.follows = "nixpkgs";
  };

  # The `outputs` attribute is a lambda that receives the `inputs`
  # attributes which are defined above.
  #
  # Here that attribute set is destructured to expose `nixpkgs`
  # and `home-manager` to the entire scope of of `outputs`,
  # but is also bound to `inputs` using the `@` syntax so that it
  # may be passed along to your modules further.
  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      inherit (nixpkgs) lib;
      # ...
    in {
      nixosConfigurations = {
        intrepid = nixpkgs.lib.nixosSystem {
          # Note that this is not the recommended way to specify the host platform.
          # The relevant changes have not really reached the docs as of 7/24/2023,
          # but if you browse the source code of this function there is a warning.
          system = "x86_64-linux";
          # Add your own modules to this list,
          # as well as any that you may want to use in your configuration.
          #
          # Note that including modules from `inputs` here is just one way to do it,
          # and not my personal preference.
          modules = [
            # These three are irrelevant to the example and are just
            # here to indicate a typical configuration.
            ./hosts/intrepid/bootloader.nix
            ./hosts/intrepid/configuration.nix
            ./hosts/intrepid/filesystems.nix
            # This one needs `inputs` to pull in `amdctl` module options.
            ./hosts/intrepid/powerplan.nix
            # You could include all the modules you need to use here,
            # but I recommend seeing the rest of the example files first.
            #
            # Omit the line below if you trust me.
            inputs.birdos.nixosModules.amdctl
          ];
          specialArgs = {
            # Add this to ensure that modules above have access to the `inputs`
            # attribute set, so that you can use `imports` later.
            inherit inputs;
            # ...
          };
        };
        # ...
      };
      # This assumes that you will use Home Manager as "standalone",
      # see the HM documentation for details.
      homeConfigurations = {
        jacob = home-manager.lib.homeManagerConfiguration {
          # This is also not the recommended way of passing `nixpkgs`,
          # for reasons (similar to `system` above) that are out-of-scope of this example.
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            # Before you ask why this is the only module--
            # when there are clearly others in the file tree--
            # please see the rest of the example files.
            ./users/jacob/profile.nix
            # Just like the `nixosSystem` example above,
            # this is my least preferred method of including
            # modules from `inputs.birdos`.
            #
            # Listing them here is possible, but wait until you see the other files.
            inputs.birdos.homeManagerModules.swayidle
            inputs.birdos.homeManagerModules.hyprland
          ];
          # Just like `specialArgs` above...
          extraSpecialArgs = {
            inherit inputs;
            # ...
          };
        };
        # ...
      };
      # ...
    };
}
```

### Contents of `hosts/intrepid/powerplan.nix`:

This file is included in the `modules` list passed to `nixpkgs.lib.nixosSystem`
as shown in the example `flake.nix`.

```nix
{ inputs, ... }: {
  # Add the `amdctl` module to the `imports` list.
  imports = [ inputs.birdos.nixosModules.amdctl ];

  # Use the options defined by that module.
  services.undervolt.amdctl = {
    enable = true;
    mode = "undervolt";
    pstateVoltages = [ 150 100 100 ];
  };

  # This is here just to show that all of the default modules from
  # Home Manager still work here.
  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 7;
    percentageAction = 5;
    criticalPowerAction = "Hibernate";
  };

  # ...
}
```

## Contents of `users/jacob/profile.nix`:

This is how I prefer to organize my [Home Manager] configuration.
Instead of adding all the modules to `modules` in the arguments to
`home-manager.lib.homeManagerConfiguration`, I prefer a more granular approach;
I only include the modules in the files in which they are used.

I use a file named `profile.nix` in the root of my user configuration,
in order to make it easy to comment out certain imports when I am experimenting.

```nix
{ config, inputs, ... }: {
  imports = [
    # Both of these relative paths are directories that contain a file called
    # `default.nix`, which is what will actually be imported.
    ./desktops/wayland
    ./desktops/hyprland
    # While I do not include modules from `inputs.birdos` here,
    # I do add `homeage` here (not shown in the example `flake.nix`).
    # This is because I directly use options from that module *in this file*.
    #
    # This has nothing to do with `birdos` modules, and is only here for
    # illustrative purposes.
    inputs.homeage.homeManagerModules.homeage
    # ...
  ];

  # You'd typically have some other commonplace
  # options from Home Manager itself defined in here too.
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";

  programs.home-manager.enable = true;
  # ...

  # This is to show usage of the `homeage` module (another flake)
  # which is imported above.
  homeage.mount = "${config.home.homeDirectory}/.secrets";
  homeage.identityPaths = [ "~/.ssh/id_ed25519" ];

  # ...
}
```

## Contents of `users/jacob/desktops/wayland/default.nix`:

```nix
{ ... }: {
  imports = [
    ./timeouts.nix
    # ...
  ];
  # ...
}
```

## Contents of `users/jacob/desktops/wayland/timeouts.nix`:

```nix
{ inputs, ... }: {
  imports = [
    # These two modules from my flake pair nicely together.
    # They are imported *in this file* because they are used *only in this file*.
    inputs.birdos.homeManagerModules.swayidle
    inputs.birdos.homeManagerModules.idlehack
  ];

  # Enabling the service from the `idlehack` module.
  services.idlehack.enable = true;

  # Usage of many options from the `swayidle` module.
  services.swayidle = {
    enable = true;
    # Only use the `systemd` targets for the desktops that you have configured.
    systemdTarget = [ "sway-session.target" "hyprland-session.target" ];
    # Actual configurations are elided for brevity.
    events = {
      # ...
    };
    batteryTimeouts = {
      # ...
    };
    pluggedInTimeouts = {
      # ...
    };
  };
}
```

## Contents of `users/jacob/desktops/hyprland/*`

If the above examples are insufficient, please open an issue and I will write
out more examples.

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

> ### List additional prelude functions
>
> You can learn what is inherited at the top-level `lib`
> (when you extend `nixpkgs.lib` as shown above)
> by printing out `lib.birdos.prelude`.
>
> ```sh
> nix eval 'github:spikespaz/dotfiles#lib.birdos.prelude' --apply 'builtins.attrNames'
> ```

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
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    birdos.url = "github:spikespaz/dotfiles";
    birdos.inputs.nixpkgs.follows = "nixpkgs";
  };

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

> ### List available packages and overlays
>
> Run this command to print out all of the available package names:
>
> ```sh
> # Replace `x86_64-linux` with the system-double of the host you're using.
> nix eval 'github:spikespaz/dotfiles#packages.x86_64-linux' --apply 'builtins.attrNames'
> ```
>
> Or this one to see the overlays:
>
> ```sh
> nix eval 'github:spikespaz/dotfiles#overlays' --apply 'builtins.attrNames'
> ```

---

# Building Configurations

This section is mostly for my personal reference,
but it is also good for the newbies so I will make it extensive.
Some of these are untested because I am writing them down when I feel clever,
if any are wrong, please open an issue.

> All commands assume that you are at the root of the cloned repository.

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
