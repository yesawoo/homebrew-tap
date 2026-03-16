class LivePhotoConv < Formula
  desc "CLI tool for processing Android live photos"
  homepage "https://github.com/wszqkzqk/live-photo-conv"
  url "https://github.com/wszqkzqk/live-photo-conv/archive/refs/tags/0.4.7.tar.gz"
  sha256 "58a136397370a58c17622e4369655879368f7cb19a2276fd4c5dc08439e5694f"
  license "LGPL-2.1-or-later"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "vala" => :build
  depends_on "gdk-pixbuf"
  depends_on "gexiv2"
  depends_on "glib"
  depends_on "gstreamer"

  def install
    # Homebrew's gexiv2 ships versioned names (gexiv2-0.16.pc, gexiv2-0.16.vapi)
    # but upstream expects unversioned "gexiv2". Create shim directories with
    # unversioned symlinks for both pkg-config and valac.
    gexiv2 = Formula["gexiv2"]
    gexiv2_ver = "#{gexiv2.version.major}.#{gexiv2.version.minor}"

    # pkg-config shim
    pc_dir = buildpath/"shims/lib/pkgconfig"
    pc_dir.mkpath
    pc_dir.install_symlink gexiv2.opt_lib/"pkgconfig/gexiv2-#{gexiv2_ver}.pc" => "gexiv2.pc"
    ENV.prepend_path "PKG_CONFIG_PATH", pc_dir

    # valac vapi shim — valac searches XDG_DATA_DIRS/vala/vapi/
    vapi_dir = buildpath/"shims/share/vala/vapi"
    vapi_dir.mkpath
    vapi_dir.install_symlink gexiv2.opt_share/"vala/vapi/gexiv2-#{gexiv2_ver}.vapi" => "gexiv2.vapi"
    deps_file = gexiv2.opt_share/"vala/vapi/gexiv2-#{gexiv2_ver}.deps"
    vapi_dir.install_symlink deps_file => "gexiv2.deps" if deps_file.exist?
    ENV.prepend_path "XDG_DATA_DIRS", buildpath/"shims/share"

    system "meson", "setup", "build", *std_meson_args,
           "-Dgir=disabled", "-Dmanpages=disabled", "-Ddocs=disabled"
    system "meson", "compile", "-C", "build"
    system "meson", "install", "-C", "build"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/live-photo-conv --version 2>&1")
  end
end
