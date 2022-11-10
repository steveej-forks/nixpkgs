{ fetchFromGitHub, stdenv, lib, pkg-config, ncurses, jdk8, gradle_6, perl
, writeText, clang, androidenv }:

let
  gradle = gradle_6;

  androidSdk = (androidenv.composeAndroidPackages {
    toolsVersion = "26.1.1";
    platformVersions = [ "32" ];
    includeEmulator = false;
    includeSystemImages = false;
    systemImageTypes = [ ];
    abiVersions = [ ];
  }).androidsdk;

  pname = "libdecsync";
  version = "v2.2.1";

  src = fetchFromGitHub {
    owner = "39aldo39";
    repo = pname;
    rev = version;
    sha256 = "sha256-MHIp8r9L8Am8h7+26eN0d/dD1A3ZK6nN0jo5aCPC2Jk=";
  };

  deps = stdenv.mkDerivation {
    name = "${pname}-deps";
    inherit src;

    nativeBuildInputs = [ jdk8 perl gradle clang ];

    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
      # export ANDROID_SDK_ROOT=undefined
      # export ANDROID_SDK_ROOT=$(mktemp -d)
      # cp -r ${androidSdk}/libexec/android-sdk/* $ANDROID_SDK_ROOT/

      gradle --no-daemon build -x test
      # patchShebangs gradlew
      # ./gradlew --no-daemon build -x test
    '';

    # Mavenize dependency paths
    # e.g. org.codehaus.groovy/groovy/2.4.0/{hash}/groovy-2.4.0.jar -> org/codehaus/groovy/groovy/2.4.0/groovy-2.4.0.jar
    installPhase = ''
      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\)' \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = lib.fakeSha256;
  };

  # Point to our local deps repo
  gradleInit = writeText "init.gradle" ''
    settingsEvaluated { settings ->
      settings.pluginManagement {
        repositories {
          clear()
          maven { url '${deps}' }
        }
      }
    }
    logger.lifecycle 'Replacing Maven repositories with ${deps}...'
    gradle.projectsLoaded {
      rootProject.allprojects {
        buildscript {
          repositories {
            clear()
            maven { url '${deps}' }
          }
        }
        repositories {
          clear()
          maven { url '${deps}' }
        }
      }
    }
  '';

in stdenv.mkDerivation rec {
  inherit pname version src;

  patches = [ ];

  buildInputs = [ ncurses ];

  nativeBuildInputs = [ jdk8 gradle pkg-config ];

  patchPhase = let
    gradleCmd =
      "gradle -PVERSION=${version} --offline --no-daemon --info --init-script ${gradleInit}";
  in ''
    substituteInPlace Makefile --replace "./gradlew" "${gradleCmd}"
    # patchShebangs gradlew
    # ln -sf ${gradle}/bin/gradle gradlew
  '';

  meta = with lib; {
    homepage = "https://github.com/39aldo39/libdecsync";
    description =
      " Evolution plugin to sync contacts and calendars without a server using DecSync ";
    # license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}

