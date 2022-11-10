{ lib, python3Packages, libdecsync }:

python3Packages.buildPythonPackage rec {
  pname = "libdecsync";
  version = "2.2.1";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-Mukjzjumv9VL+A0maU0K/SliWrgeRjAeiEdN5a83G0I=";
  };

  propagatedBuildInputs = [ libdecsync ];
  meta = with lib; {
    description =
      "libdecsync is a Python3 wrapper around libdecsync for synchronizing using DecSync";
    homepage = "https://github.com/39aldo39/libdecsync-bindings-python3";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ethancedwards8 ];
    platforms = platforms.linux;
  };
}
