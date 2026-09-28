# The `version`, `sha256` and `depends_on macos:` lines are rewritten by the
# PodSteer release workflow on every production release — do not hand-edit
# those three. Everything else here, the caveats and the zap list especially,
# is prose the workflow preserves and nothing generates: it is maintained by
# hand, in this file.
#
# A CASK, not a formula, because PodSteer is a GUI application. A formula puts an
# executable on your PATH; a cask installs an .app into /Applications where the
# Dock, Spotlight and Launchpad can find it. Installing a windowed application
# through a formula leaves it invisible to all three.
cask "podsteer" do
  # One universal build covers Apple Silicon and Intel, so there is a single
  # URL and a single checksum rather than an arch conditional.
  version "0.4.0"
  sha256 "0047a147312f5052a09ac45ae5eb841df991f339bc40233522a3d0300dda844a"

  url "https://github.com/podsteer/podsteer/releases/download/v#{version}/podsteer_v#{version}_macos-universal.zip"
  name "PodSteer"
  desc "Native Kubernetes client that tells you what is wrong"
  homepage "https://podsteer.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # REWRITTEN BY THE RELEASE WORKFLOW, so do not move it by hand. It is read
  # out of LSMinimumSystemVersion in the bundle this cask is about to serve
  # and mapped through a table that FAILS the release on a macOS version it
  # does not know, rather than guessing one.
  #
  # It is derived because it went stale twice while it was not. It read
  # `">= :high_sierra"` for three releases — wrong twice over, since the
  # string form is deprecated (a bare symbol already means "this version or
  # newer") and :high_sierra has since been removed from Homebrew altogether.
  # Corrected by hand to :big_sur, it was then about to be wrong again by two
  # major versions the moment the application's floor moved to Ventura.
  #
  # The value here is whatever the last production release declared. v0.2.0
  # declared 10.13.0, matching its x86_64 slice — that slice carries the older
  # LC_VERSION_MIN_MACOSX at 10.13 while arm64 carries LC_BUILD_VERSION at
  # 11.0, which is correct rather than a mismatch, because Apple Silicon did
  # not exist before macOS 11. PodSteer's own build asserts the plist against
  # the LOWEST slice, which is what makes reading the plist here sound.
  depends_on macos: :ventura

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
    PodSteer reads your existing kubeconfig and talks to the clusters it names.
    No account and no telemetry. The one other call is a once-a-day update
    check to api.github.com carrying no identifier; turn it off in Settings or
    with PODSTEER_UPDATE_CHECK=false.
  EOS
end
