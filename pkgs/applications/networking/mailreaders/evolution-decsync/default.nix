{ callPackage, fetchFromGitHub, git, makeWrapper, meson, ninja, pkg-config, lib
, stdenv, libe-book, evolution-data-server, evolution, gtk3, webkitgtk, cmake
, libdecsync ? callPackage ./libdecsync { } }:

stdenv.mkDerivation rec {
  pname = "Evolution-DecSync";
  version = "v2.1.0-evolution-3.44";

  src = fetchFromGitHub {
    owner = "39aldo39";
    repo = pname;
    rev = version;
    sha256 = "sha256-5AdL3sKQjMe+gINebWivSAqoVRUbQjCIm8bNoDZTP4A=";
  };

  patches = [ ];

  buildInputs =
    [ evolution-data-server libe-book evolution gtk3 webkitgtk libdecsync ];

  nativeBuildInputs = [ meson ninja pkg-config cmake ];

  meta = with lib; {
    homepage = "https://github.com/39aldo39/Evolution-DecSync";
    description =
      " Evolution plugin to sync contacts and calendars without a server using DecSync ";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
