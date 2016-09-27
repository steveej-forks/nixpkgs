{ stdenv, fetchurl, makeWrapper, glib
, fontconfig, patchelf, libXext, libX11
, freetype, libXrender
, ffmpeg, nss, nspr
}:

let
  arch = if stdenv.system == "x86_64-linux" then "amd"
    else if stdenv.system == "i686-linux" then "i386"
    else throw "Encryptr for: ${stdenv.system} not supported!";

  interpreter = if stdenv.system == "x86_64-linux" then "ld-linux-x86-64.so.2"
    else if stdenv.system == "i686-linux" then "ld-linux.so.2"
    else throw "Encryptr for: ${stdenv.system} not supported!";

  sha256 = if stdenv.system == "x86_64-linux" then "1j3g467g7ar86hpnh6q9mf7mh2h4ia94mwhk1283zh739s2g53q2"
    else if stdenv.system == "i686-linux" then "02j9hg9b1jlv25q1sjfhv8d46mii33f94dj0ccn83z9z18q4y2cm"
    else throw "Encryptr for: ${stdenv.system} not supported!";

  ldpath = stdenv.lib.makeLibraryPath [
    glib fontconfig libXext libX11 freetype libXrender ffmpeg nss nspr
  ];


in stdenv.mkDerivation rec {
  name = "encryptr-${version}";
  version = "2.0.0";

  src = fetchurl {
    name = "encryptr-${version}-${arch}";
    url = "https://spideroak.com/dist/encryptr/signed/linux/targz/${name}_${arch}.tar.gz";
    inherit sha256;
  };

  sourceRoot = ".";

  unpackCmd = "tar -xzf $curSrc";

  installPhase = ''
    mkdir -p $out/opt/Encryptr
    mkdir $out/bin

    mv ./Encryptr/{icudtl.dat,nw.pak} $out/opt/Encryptr
    mv ./Encryptr/encryptr-bin $out/bin/encryptr

    patchelf --set-interpreter ${stdenv.glibc.out}/lib/${interpreter} \
      "$out/bin/encryptr"

    wrapProgram $out/bin/encryptr \
      --prefix LD_LIBRARY_PATH : ${ldpath}
  '';

  buildInputs = [ patchelf makeWrapper ];

  meta = {
    homepage = "https://spideroak.com";
    description = "Secure online backup and sychronization";
    license = stdenv.lib.licenses.unfree;
    maintainers = with stdenv.lib.maintainers; [ stevee ];
    platforms = stdenv.lib.platforms.linux;
  };
}
