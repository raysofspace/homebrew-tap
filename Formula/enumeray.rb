require "json"

class Enumeray < Formula
  desc "Run scientific models through an authorized Enumeray service"
  homepage "https://enumeray.com"
  version "0.1.0-alpha.2"
  license "Apache-2.0"

  depends_on :macos

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/raysofspace/enumeray-cli/releases/download/v0.1.0-alpha.2/enumeray-0.1.0-alpha.2-aarch64-apple-darwin.tar.gz"
      sha256 "5ba584a2f8050058da115192f5d17b5f163412d0e993bffc7058f775694a6536"
    end
    on_intel do
      url "https://github.com/raysofspace/enumeray-cli/releases/download/v0.1.0-alpha.2/enumeray-0.1.0-alpha.2-x86_64-apple-darwin.tar.gz"
      sha256 "229610111a82738c4253aeeec5368b5e2c9edff4798cf9fcfa7df7cfe0fc0f78"
    end
  end

  def install
    bin.install "enumeray"
    prefix.install "LICENSE"
    pkgshare.install Dir["*.md", "*.json", "examples", "starter-kit"]
  end

  def caveats
    <<~EOS
      This release may be an alpha, as indicated by its version. Alpha updates
      may require a fresh installation; no in-place alpha upgrade is promised.
      Preserve existing state and matching binaries before changing versions.
      Connector and compute-runner hosts need the matching qualified release.
      Stop the connector daemon before replacing its executable; preserve its
      credentials and journal, coordinate runner replacement, and restart explicitly.
      Compatibility metadata and offline guides are in #{pkgshare}.
    EOS
  end

  test do
    assert_equal "enumeray #{version}", shell_output("#{bin}/enumeray --version").strip
    assert_match "connector", shell_output("#{bin}/enumeray --help")
    journal = testpath/"qualification-journal"
    initialized = JSON.parse(shell_output("#{bin}/enumeray connector init --journal #{journal} " \
                                         "--api-base-url http://127.0.0.1:8080 " \
                                         "--connector-id homebrew-qualification"))
    inspected = JSON.parse(shell_output("#{bin}/enumeray connector inspect --journal #{journal}"))
    assert_equal initialized.fetch("journal_id"), inspected.fetch("journal_id")
  end
end
