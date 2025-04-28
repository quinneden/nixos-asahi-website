---
layout: page
title: Installation & Building
---

## Installation

Using the installer script:

```bash
sh <(curl -sL "https://nixos-asahi.qeden.dev/install")
```

This is a modified copy of the bootstrap script from the [asahi-installer](https://github.com/asahilinux/asahi-installer) repository. Be sure to follow the instructions carefully, as it is possible a mistake could leave your system in an unbootable state.

## Building the flake outputs

> [!NOTE]
> An aarch64-linux machine is required to build the NixOS disk image. See the [darwin-builder section](https://nixos.org/manual/nixpkgs/stable/#sec-darwin-builder) of the nixpkgs manual for information on setting up a nix builder vm on MacOS.

```bash
nix build .#packages.aarch64-linux.installerPackage
# builds the pkg for the asahi installer

nix build .#packages.aarch64-linux.btrfsImage # or .ext4Image
# builds just the disk image
```

By default, `installerPackage` consumes `btrfsImage` as the image used to build the installer package but `ext4Image` could be used in its place.

```nix
# ...
installerPackage = pkgs.callPackage ./package.nix {
  inherit lib version;
  image = btrfsImage; # ext4Image
};
```

## Credits

- [tpwrules/nixos-apple-silicon](https://github.com/tpwrules/nixos-apple-silicon)
- [Asahi Linux](https://github.com/asahilinux)

## License

The Nix derivations and documentation in this repository are licensed under the MIT license as included in the LICENSE file. Patches included in this repository, and the files that Nix builds, are covered by separate licenses.
