require "json"

class Enumeray < Formula
  desc "Run scientific models through an authorized Enumeray service"
  homepage "https://enumeray.com"
  version "0.1.0-alpha.1"
  license "Apache-2.0"

  depends_on :macos

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/raysofspace/enumeray-cli/releases/download/v0.1.0-alpha.1/enumeray-0.1.0-alpha.1-aarch64-apple-darwin.tar.gz"
      sha256 "9da89bd8a93e6393c904048ed9122837672accad21ef2fbbd94a8f0acf2461a4"
    end
    on_intel do
      url "https://github.com/raysofspace/enumeray-cli/releases/download/v0.1.0-alpha.1/enumeray-0.1.0-alpha.1-x86_64-apple-darwin.tar.gz"
      sha256 "d0965b8235a876c8b1fb4e131460a23e8c2da370e1e2501dbe719198c38c7000"
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
