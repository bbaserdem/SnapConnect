{
  description = "Flake Mobile app development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        # Nixpkgs, we need unfree packages, and accepted licences
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          android_sdk.accept_license = true;
        };
        # Modify this as needed, as of 06-2025 sdk 36 is the most current sdk
        # Play store requires 34 as a hard requirement
        # I'm using the most recent versions from nixpkgs-unstable
        cmdLineToolsVersion = "13.0";
        platformToolsVersion = "latest";
        buildToolsVersion = "35.0.0";
        ndkVersions = ["26.3.11579264" "27.0.12077973"];
        cmakeVersion = "3.22.1";
        # Creating our android dev environment
        androidEnv = pkgs.androidenv.override {licenseAccepted = true;};
        androidCmp = androidEnv.composeAndroidPackages {
          inherit cmdLineToolsVersion platformToolsVersion;
          buildToolsVersions = [buildToolsVersion];
          platformVersions = ["33" "34" "35" "36"];
          abiVersions = ["armeabi-v7a" "arm64-v8a" "x86_64"];
          includeNDK = true;
          ndkVersions = ndkVersions;
          cmakeVersions = [cmakeVersion];
          includeSystemImages = true;
          systemImageTypes = ["google_apis" "google_apis_playstore"];
          includeEmulator = true;
          useGoogleAPIs = true;
          extraLicenses = [
            # Grab all licenses
            "android-googletv-license"
            "android-sdk-arm-dbt-license"
            "android-sdk-license"
            "android-sdk-preview-license"
            "google-gdk-license"
            "intel-android-extra-license"
            "intel-android-sysimage-license"
            "mips-android-sysimage-license"
          ];
        };
        devSdk = androidCmp.androidsdk;
        # RAG toolkit with python; as of 06-2025 python 3.13 is the version with pkgs
        devPython = pkgs.python313.withPackages (python-pkgs:
          with python-pkgs; [
            # Auto tagging function packages
            openai
            firebase-admin
            google-cloud-storage
            google-cloud-firestore
            faiss
            numpy
            # Tools for python development
            jupyter
            ipython
          ]);
      in {
        devShells.default = pkgs.mkShell rec {
          ANDROID_HOME = "${devSdk}/libexec/android-sdk";
          ANDROID_SDK_ROOT = "${ANDROID_HOME}";
          ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";
          CMDLINE_TOOLS_ROOT = "${devSdk}/libexec/android-sdk/cmdline-tools/${cmdLineToolsVersion}";
          JAVA_HOME = "${pkgs.jdk21}";
          FLUTTER_ROOT = pkgs.flutter;
          DART_ROOT = "${pkgs.flutter}/bin/cache/dart-sdk";
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${devSdk}/libexec/android-sdk/build-tools/${buildToolsVersion}/aapt2";
          # emulator related: try using wayland, otherwise fall back to X.
          # NB: due to the emulator's bundled qt version, it currently does not start with QT_QPA_PLATFORM="wayland".
          # Maybe one day this will be supported.
          QT_QPA_PLATFORM = "wayland;xcb";

          # Android Emulator Performance Optimizations
          # Enable KVM hardware acceleration for faster emulation
          # Note: ANDROID_EMULATOR_USE_SYSTEM_LIBS is NOT set in NixOS as it conflicts with Nix store paths
          QEMU_OPTS = "-machine accel=kvm";

          buildInputs = with pkgs; [
            # Build tools & languages
            flutter
            gradle
            jdk21
            jdk17
            pkg-config
            # Android build
            devSdk
            # Linux build
            gtk3
            # Emulation
            qemu_kvm
            mesa-demos
            ffmpeg
            # Service management
            devPython
            firebase-tools
            libsecret
          ];
          # emulator related: vulkan-loader and libGL shared libs are necessary for hardware decoding
          LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [pkgs.vulkan-loader pkgs.libGL]}";
          # Globally installed packages, which are installed through `dart pub global activate package_name`,
          # are located in the `$PUB_CACHE/bin` directory.
          shellHook = ''
            # Configure Gradle to find the JDK 17 toolchain in the Nix store.
            export GRADLE_OPTS="-Dorg.gradle.java.installations.paths=${pkgs.jdk17} $GRADLE_OPTS"

            # Dart/Flutter pub cache setup
            if [ -z "$PUB_CACHE" ]; then
              export PATH="$PATH:$HOME/.pub-cache/bin"
            else
              export PATH="$PATH:$PUB_CACHE/bin"
            fi

            # Add Android cmdline-tools to PATH for Flutter
            export PATH="$PATH:${devSdk}/libexec/android-sdk/cmdline-tools/${cmdLineToolsVersion}/bin"

            # Add cmake to path
            export PATH="$(echo "$ANDROID_HOME/cmake/${cmakeVersion}".*/bin):$PATH"

            # Write out local.properties for Android Studio.
            cat <<EOF > local.properties
            # This file was automatically generated by nix-shell.
            sdk.dir=$ANDROID_SDK_ROOT
            ndk.dir=$ANDROID_NDK_ROOT
            cmake.dir=$ANDROID_HOME/cmake/${cmakeVersion}
            EOF
          '';
        };
      }
    );
}
