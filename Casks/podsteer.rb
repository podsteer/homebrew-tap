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
  version "0.0.0"

  # One universal build covers Apple Silicon and Intel, so there is a single
  # URL and a single checksum rather than an arch conditional.
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/podsteer/podsteer/releases/download/v#{version}/podsteer_v#{version}_macos-universal.zip"
  name "PodSteer"
  desc "Native Kubernetes client that tells you what is wrong"
  homepage "https://podsteer.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Wails builds an unsigned bundle, so macOS refuses to open it until the
  # quarantine flag is cleared. `auto_updates false` and this depends_on are
  # honest metadata rather than a workaround; see the caveat below.
  depends_on macos: ">= :high_sierra"

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

  caveats <<~EOS
    PodSteer is not yet signed with an Apple Developer ID, so macOS will refuse
    to open it the first time with "PodSteer is damaged and can't be opened".
    It is not damaged — that is Gatekeeper reporting an unsigned download.

    Clear the quarantine flag once:

      xattr -dr com.apple.quarantine /Applications/PodSteer.app

    PodSteer reads your existing kubeconfig and talks only to the clusters it
    names. It sends nothing anywhere else.
  EOS
end
