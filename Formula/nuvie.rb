class Nuvie < Formula
  desc "The Ultima 6 engine"
  homepage "https://nuvie.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/nuvie/Nuvie/0.5/nuvie-0.5.tgz"
  sha256 "ff026f6d569d006d9fe954f44fdf0c2276dbf129b0fc5c0d4ef8dce01f0fc257"

  bottle do
    cellar :any
    rebuild 1
    sha256 "286980f2c5b977f355d59bf2b10366b3c38613764b66707852e2934649089bc6" => :catalina
    sha256 "b1cefbd62e4b350d330853e14f789cc0b137c19b434271d1837114e10a73b0ca" => :mojave
    sha256 "f066beb078dd00f4b339ce25b7ff06dadd6ddf62283008ee149d2758c80e439b" => :high_sierra
  end

  head do
    url "https://github.com/nuvie/nuvie.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "sdl"

  def install
    inreplace "./nuvie.cpp" do |s|
      s.gsub! 'datadir", "./data"',
              "datadir\", \"#{lib}/data\""
      s.gsub! 'home + "/Library',
              '"/Library'
      s.gsub! 'config_path.append("/Library/Preferences/Nuvie Preferences");',
              "config_path = \"#{var}/nuvie/nuvie.cfg\";"
      s.gsub! "/Library/Application Support/Nuvie Support/",
              "#{var}/nuvie/game/"
      s.gsub! "/Library/Application Support/Nuvie/",
              "#{var}/nuvie/"
    end
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-sdltest",
                          "--prefix=#{prefix}"
    system "make"
    bin.install "nuvie"
    pkgshare.install "data"
  end

  def post_install
    (var/"nuvie/game").mkpath
  end

  def caveats; <<~EOS
    Copy your Ultima 6 game files into the following directory:
      #{var}/nuvie/game/ultima6/
    Save games will be stored in the following directory:
      #{var}/nuvie/savegames/
    Config file will be located at:
      #{var}/nuvie/nuvie.cfg
  EOS
  end

  test do
    pid = fork do
      exec bin/"nuvie"
    end
    sleep 3

    assert_predicate bin/"nuvie", :exist?
    assert_predicate bin/"nuvie", :executable?
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
