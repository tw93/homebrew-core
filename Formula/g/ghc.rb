class Ghc < Formula
  desc "Glorious Glasgow Haskell Compilation System"
  homepage "https://haskell.org/ghc/"
  url "https://downloads.haskell.org/~ghc/9.14.1/ghc-9.14.1-src.tar.xz"
  sha256 "2a83779c9af86554a3289f2787a38d6aa83d00d136aa9f920361dd693c101e77"
  license "BSD-3-Clause"
  head "https://gitlab.haskell.org/ghc/ghc.git", branch: "master"

  livecheck do
    url "https://www.haskell.org/ghc/"
    regex(/href=.*?download[_-]ghc[_-]v?(\d+(?:[._]\d+)+)\.html/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match[0].tr("_", ".") }
    end
  end

  bottle do
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:   "395f99ab0aa762bce9f4a2de022139ce9852464bd5c88daefb80afbb7e84d602"
    sha256 cellar: :any, arm64_sequoia: "91d82d69656f28ec22846128f6d28205b8f99f8a7abcce0406c309c394cef384"
    sha256 cellar: :any, arm64_sonoma:  "9de5f90e23350b914387674883157faa793a58619d87ece4f9bc90fe5001737c"
    sha256 cellar: :any, arm64_ventura: "1027b79cd2c730cc7268f5f1582fa94a23cb66c99d1d937f5395379e1e5c7d2b"
    sha256 cellar: :any, sonoma:        "9a399cf1d62161f0d278b106af0dd02f5ba2bad96d911e1a96704bca34985914"
    sha256 cellar: :any, ventura:       "ef06c3ecf24f8855afe44cd10f40088db82aead9ac408425fdf731e73a70c41b"
    sha256               arm64_linux:   "787493ddf23e1220aa1cda774272ac80bbfeb95a0ee69f585c1836c32dd18d10"
    sha256               x86_64_linux:  "8ddfb5d203315132ae9a5ea1f05a3398bf781c1e41b077cd2c88084dbce548c8"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "python@3.14" => :build
  depends_on "sphinx-doc" => :build
  depends_on "xz" => :build
  depends_on "gmp"

  uses_from_macos "m4" => :build
  uses_from_macos "libffi"
  uses_from_macos "ncurses"

  # Build uses sed -r option, which is not available in Catalina shipped sed.
  on_catalina :or_older do
    depends_on "gnu-sed" => :build
  end

  on_linux do
    on_arm do
      depends_on "gcc" => :build if DevelopmentTools.gcc_version("gcc") < 12

      fails_with :gcc do
        version "11"
        cause <<~CAUSE
          _build/stage1/compiler/build/GHC.p_dyn_o:(.text..LsO3B_info+0x198):
          relocation truncated to fit: R_AARCH64_JUMP26 against symbol
          `ghczm9zi12zi2zminplace_GHCziUtilsziPanic_showGhcException_info'
          defined in .text.ghczm9zi12zi2zminplace_GHCziUtilsziPanic_showGhcException_info
          section in _build/stage1/compiler/build/GHC/Utils/Panic.p_dyn_o
        CAUSE
      end
    end
  end

  # A binary of ghc is needed to bootstrap ghc
  resource "binary" do
    on_macos do
      on_arm do
        url "https://downloads.haskell.org/~ghc/9.12.2/ghc-9.12.2-aarch64-apple-darwin.tar.xz"
        sha256 "4b61b933028c63ace950236ea3382d02e51a3d9cbd1ca3f6cf4fe14c71ff436c"
      end
      on_intel do
        url "https://downloads.haskell.org/~ghc/9.12.2/ghc-9.12.2-x86_64-apple-darwin.tar.xz"
        sha256 "e7a40e39059dd3619d7884b7382f357e79a0f4e430181b805bdd57b3be9a7300"
      end
    end
    on_linux do
      on_arm do
        url "https://downloads.haskell.org/~ghc/9.12.2/ghc-9.12.2-aarch64-deb10-linux.tar.xz"
        sha256 "6048eae62ede069459398fa6f2e92ab9719e1b83e93a9014e6a410c54ed2755f"
      end
      on_intel do
        url "https://downloads.haskell.org/~ghc/9.12.2/ghc-9.12.2-x86_64-ubuntu20_04-linux.tar.xz"
        sha256 "0cffff0a74131465bb5d1447400ea46080a10e3cd46d6c9559aa6f2a6a7537ac"
      end
    end
  end

  resource "cabal-install" do
    on_macos do
      on_arm do
        url "https://downloads.haskell.org/~cabal/cabal-install-3.16.0.0/cabal-install-3.16.0.0-aarch64-darwin.tar.xz"
        sha256 "8e7aa8823f9c0d9c4c75b69051ebd405b29e2f1a8a1862fcc96df79578ffea1d"
      end
      on_intel do
        url "https://downloads.haskell.org/~cabal/cabal-install-3.16.0.0/cabal-install-3.16.0.0-x86_64-darwin.tar.xz"
        sha256 "d3a74742caf998c1627a457de095c7d263680d96d38a7582cd3f9746bff76423"
      end
    end
    on_linux do
      on_arm do
        url "https://downloads.haskell.org/~cabal/cabal-install-3.16.0.0/cabal-install-3.16.0.0-aarch64-linux-deb10.tar.xz"
        sha256 "e3954219856990e6013b82dc23fe1be263161d511d687244ccf45cdc2cbac3f4"
      end
      on_intel do
        url "https://downloads.haskell.org/~cabal/cabal-install-3.16.0.0/cabal-install-3.16.0.0-x86_64-linux-ubuntu20_04.tar.xz"
        sha256 "b187b53cb4b3a0a55f1d2e7f0f0198bb57fbdb44cd08957adffe6b74b764c6b2"
      end
    end
  end

  def install
    # ENV.cc and ENV.cxx return specific compiler versions on Ubuntu, e.g.
    # gcc-11 and g++-11 on Ubuntu 22.04. Using such values effectively causes
    # the bottle (binary package) to only run on systems where gcc-11 and g++-11
    # binaries are available. This breaks on many systems including Arch Linux,
    # Fedora and Ubuntu 24.04, as they provide g** but not g**-11 specifically.
    #
    # The workaround here is to hard-code both CC and CXX on Linux.
    ENV["CC"] = ENV["ac_cv_path_CC"] = OS.linux? ? "cc" : ENV.cc
    ENV["CXX"] = ENV["ac_cv_path_CXX"] = OS.linux? ? "c++" : ENV.cxx
    ENV["LD"] = ENV["MergeObjsCmd"] = "ld"
    ENV["PYTHON"] = which("python3.14")

    # Workaround for https://gitlab.haskell.org/ghc/ghc/-/issues/26166
    if DevelopmentTools.ld64_version == "1221.4"
      inreplace "rts/rts.cabal", /("-Wl,-undefined,dynamic_lookup)"/, "\\1,-ld_classic\""
    end

    binary = buildpath/"binary"
    args = %W[
      --with-gmp-includes=#{Formula["gmp"].opt_include}
      --with-gmp-libraries=#{Formula["gmp"].opt_lib}
    ]
    resource("binary").stage do
      system "./configure", "--prefix=#{binary}", *args
      ENV.deparallelize { system "make", "install" }
    end

    ENV.prepend_path "PATH", binary/"bin"
    # Build uses sed -r option, which is not available in Catalina shipped sed.
    ENV.prepend_path "PATH", Formula["gnu-sed"].libexec/"gnubin" if OS.mac? && MacOS.version <= :catalina

    resource("cabal-install").stage { (binary/"bin").install "cabal" }
    system "cabal", "v2-update"
    if build.head?
      cabal_args = std_cabal_v2_args.reject { |s| s["installdir"] }
      system "cabal", "v2-install", "alex", "happy", *cabal_args, "--installdir=#{binary}/bin"
      system "./boot"
    end

    if OS.mac?
      # https://gitlab.haskell.org/ghc/ghc/-/issues/22595#note_468423
      args << "--with-ffi-libraries=#{MacOS.sdk_path_if_needed}/usr/lib"
      args << "--with-ffi-includes=#{MacOS.sdk_path_if_needed}/usr/include/ffi"
    end

    system "./configure", "--prefix=#{prefix}", "--disable-numa", "--with-system-libffi", *args
    hadrian_args = %W[
      -j#{ENV.make_jobs}
      --prefix=#{prefix}
      --flavour=release
      --docs=no-sphinx-pdfs
    ]
    # Let hadrian handle its own parallelization
    ENV.deparallelize { system "hadrian/build", "install", *hadrian_args }

    bash_completion.install "utils/completion/ghc.bash" => "ghc"
    ghc_libdir = build.head? ? lib.glob("ghc-*").first : lib/"ghc-#{version}"
    (ghc_libdir/"lib/package.conf.d/package.cache").unlink
    (ghc_libdir/"lib/package.conf.d/package.cache.lock").unlink
  end

  def post_install
    system bin/"ghc-pkg", "recache"
  end

  test do
    (testpath/"hello.hs").write('main = putStrLn "Hello Homebrew"')
    assert_match "Hello Homebrew", shell_output("#{bin}/runghc hello.hs")
  end
end
