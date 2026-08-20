# PodSteer Homebrew tap

Install [PodSteer](https://github.com/podsteer/podsteer), a native desktop
Kubernetes client, on macOS.

```sh
brew tap podsteer/tap
brew install --cask podsteer
```

Upgrade with `brew upgrade --cask podsteer`, remove with
`brew uninstall --cask podsteer`, and remove its recorded cluster history too
with `brew uninstall --zap --cask podsteer`.

## Why a cask and not a formula

PodSteer is a windowed application. A formula puts an executable on your `PATH`;
a cask installs an `.app` into `/Applications`, where the Dock, Spotlight and
Launchpad can find it. Installing a GUI application through a formula leaves it
invisible to all three.

## The Gatekeeper warning is expected

PodSteer is not yet signed with an Apple Developer ID. The first launch after
installing will fail with **"PodSteer is damaged and can't be opened"**. It is
not damaged; that is macOS reporting an unsigned download, and every unsigned
application says the same thing.

Clear the quarantine flag once:

```sh
xattr -dr com.apple.quarantine /Applications/PodSteer.app
```

Signing and notarising the release is [tracked
upstream](https://github.com/podsteer/podsteer/issues) and will remove this step.
Until it lands, verify what you are running against the checksums published
with each release rather than trusting the download:

```sh
shasum -a 256 ~/Downloads/podsteer_v*_macos-universal.zip
```

## Linux and Windows

Not served by this tap. Homebrew on Linux installs into its own prefix and has
no concept of a desktop entry, so a GUI application installed that way appears
in no launcher. Download the archive from
[Releases](https://github.com/podsteer/podsteer/releases) instead.

## What this repository contains

`Casks/podsteer.rb`, rewritten by the PodSteer release workflow on every
production tag — the version, the URL and the SHA-256 all come from the release
that was just published. Hand-editing it means the next release overwrites your
change.
