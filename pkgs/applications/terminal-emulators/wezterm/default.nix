{ rustPlatform
, lib
, fetchFromGitHub

, pkgconfig
, fontconfig
, python3
, openssl
, gcc
, perl

, dbus
, libX11
, xcbutil
, libxcb
, xcbutilkeysyms
, xcbutilwm # contains xcb-ewmh among others
, libxkbcommon
, libglvnd # libEGL.so.1
, egl-wayland
, wayland
, libGLU
, libGL
, freetype
, zlib
}:
let
  nativeBuildInputs = [
    pkgconfig
    python3
    openssl.dev
    # cc
    perl

    fontconfig
    freetype
  ];

  runtimeDeps = [
    libX11
    xcbutil
    libxcb
    xcbutilkeysyms
    xcbutilwm
    libxkbcommon
    dbus
    libglvnd
    zlib

    # double-check
    egl-wayland
    wayland
    libGLU
    libGL
    fontconfig
    freetype
  ];

  pname = "wezterm";
  version = "3bd8d8c84591f4d015ff9a47ddb478e55c231fda";
in
rustPlatform.buildRustPackage {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    owner = "wez";
    repo = pname;
    rev = "${version}";
    fetchSubmodules = true;
    sha256 = "13xf3685kir4p159hsxrqkj9p2lwgfp0n13h9zadslrd44l8b8j8";
  };
  # src = /home/steveej/src/others/wezterm;

  # cargoExtraManifests = [
  #   "deps/fontconfig/Cargo.toml"
  #   "deps/freetype/Cargo.toml"
  #   "deps/harfbuzz/Cargo.toml"
  # ];

  cargoSha256 = "0ri79aiipy93dabiwp1jgsy1pgwrdr38n6wrp5j568m7cqbdrmwn";

  nativeBuildInputs = [
    pkgconfig
    fontconfig
    python3
    openssl.dev
    # cc
    perl

    fontconfig
  ];

  buildInputs = [ 
  ] ++ runtimeDeps;

  outputs = [ "out" ];

  installPhase = ''
    runHook preInstall

    (
    set -x
    releaseDir=''${releaseDir:?}
    for artifact in wezterm wezterm-gui wezterm-mux-server strip-ansi-escapes; do
      patchelf --set-rpath "${lib.makeLibraryPath runtimeDeps}" $releaseDir/$artifact
      install -D $releaseDir/$artifact $out/bin/$artifact
    done
    )

    runHook postInstall
  '';

  # prevent further changes to the RPATH
  dontPatchELF = true;

  meta = with lib; {
    description = "A GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust";
    homepage = "https://wezfurlong.org/wezterm";
    # license = licenses.angle;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
  };
}
