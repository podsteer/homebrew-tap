# The `version` and `sha256` lines are rewritten by the PodSteer release
# workflow on every production release — do not hand-edit those two. Everything
# else here, the caveats and the zap list especially, is prose the workflow
# preserves and nothing generates: it is maintained by hand, in this file.
#
# A CASK, not a formula, because PodSteer is a GUI application. A formula puts an
# executable on your PATH; a cask installs an .app into /Applications where the
# Dock, Spotlight and Launchpad can find it. Installing a windowed application
# through a formula leaves it invisible to all three.
cask "podsteer" do
  version "0.2.0"

  # One universal build covers Apple Silicon and Intel, so there is a single
  # URL and a single checksum rather than an arch conditional.
  sha256 "cab54e378448fe3ae9ad0670da838a6f06a343df6799c373aaee2870f4459224"

  url "https://github.com/podsteer/podsteer/releases/download/v#{version}/podsteer_v#{version}_macos-universal.zip"
  name "PodSteer"
  desc "Native Kubernetes client that tells you what is wrong"
  homepage "https://podsteer.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # BIG SUR BECAUSE THAT IS WHAT THE BINARY SAYS. `otool -l` reports
  # `minos 11.0` on both slices of the universal build, so this is read off
  # the artefact rather than chosen.
  #
  # It was `">= :high_sierra"`, which was wrong twice over. The string
  # comparison form is deprecated — a bare symbol already means "this version
  # or newer" — and :high_sierra has since been REMOVED from Homebrew
  # altogether, so the symbol form of it is disabled with no replacement. The
  # oldest symbol Homebrew still knows is :catalina.
  #
  # Homebrew's own source marks Big Sur for removal in September 2027 or
  # later. When that lands this line has to move up, and the binary's minos
  # is where to look for what to move it to.
  depends_on macos: :big_sur

  app "PodSteer.app"

  # Everything PodSteer writes, and it writes in two places rather than one.
  #
  # Application Support holds the recorded cluster history and its retention
  # setting. The WebKit and Caches entries hold the interface's own display
  # preferences — theme, page size, column widths — which live in the webview's
  # local storage under the bundle identifier, not beside the history. Listing
  # only Application Support left those behind on every uninstall, which made
  # the "uninstalling removes it" claim on podsteer.com untrue.
  #
  # Removing all of it is what somebody uninstalling expects: it is a local
  # cache of figures and window preferences, not anything they authored.
  zap trash: [
    "~/Library/Application Support/PodSteer",
    "~/Library/Caches/com.podsteer.desktop",
    "~/Library/HTTPStorages/com.podsteer.desktop",
    "~/Library/Preferences/com.podsteer.desktop.plist",
    "~/Library/Saved Application State/com.podsteer.desktop.savedState",
    "~/Library/WebKit/com.podsteer.desktop",
  ]

  # NO QUARANTINE INSTRUCTION. This used to tell people to run `xattr -dr
  # com.apple.quarantine` because the build was unsigned. It is now signed with
  # a Developer ID, notarised, and the ticket is stapled — Gatekeeper reports
  # "accepted, source=Notarized Developer ID" — so that advice became both
  # untrue and actively harmful: stripping quarantine is a habit worth nobody
  # learning, and teaching it for an app that does not need it is how somebody
  # later applies it to one that does.
  caveats <<~EOS
    PodSteer reads your existing kubeconfig and talks only to the clusters it
    names. It sends nothing anywhere else: no account, no telemetry, and no
    update check.
  EOS
end
