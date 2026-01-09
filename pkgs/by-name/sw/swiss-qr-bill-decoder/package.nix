{
  lib,
  fetchFromGitHub,
  ghostscript,
  makeWrapper,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "swiss-qr-bill-decoder";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "smartive";
    repo = "swiss-qr-bill-decoder";
    rev = "v${version}";
    hash = "sha256-bnjWlUF6aRwda/VjjJqGlGmrgIbmF4Y5Ge9CQ1fBgQY=";
  };

  cargoHash = "sha256-o7Iq2mt5MN2rnE627dzWuU4B1kRuDv3D+DPbwwuK9sc=";

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ ghostscript ];

  postInstall = ''
    wrapProgram $out/bin/swiss-qr-bill-decoder \
      --prefix PATH : ${lib.makeBinPath [ ghostscript ]}
  '';

  meta = {
    description = "Tool to decode QR codes of Swiss QR bills";
    homepage = "https://github.com/smartive/swiss-qr-bill-decoder";
    license = lib.licenses.mit;
    mainProgram = "swiss-qr-bill-decoder";
    maintainers = with lib.maintainers; [ steveej ];
    platforms = lib.platforms.unix;
  };
}
