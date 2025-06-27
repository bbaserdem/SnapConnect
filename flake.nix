# From https://manuelplavsic.ch/articles/flutter-environment-with-nix/
{
  description = "SnapConnect - GauntletAI Project 02";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          android_sdk.accept_license = true;
        };
        cmakeVersion = "3.22.1";
        buildToolsVersion = "33.0.2";
        androidEnv = pkgs.androidenv.override {licenseAccepted = true;};
        androidComposition = androidEnv.composeAndroidPackages {
          cmdLineToolsVersion = "8.0";
          platformToolsVersion = "34.0.4";
          buildToolsVersions = [buildToolsVersion "34.0.0" "35.0.0" "36.0.0"];
          platformVersions = ["33" "34" "35" "36"];
          abiVersions = ["armeabi-v7a" "arm64-v8a" "x86_64"];
          includeNDK = true;
          ndkVersions = ["27.0.12077973"];
          cmakeVersions = [cmakeVersion];
          includeSystemImages = true;
          systemImageTypes = ["google_apis" "google_apis_playstore"];
          includeEmulator = true;
          useGoogleAPIs = true;
          extraLicenses = [
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
        androidSdk = androidComposition.androidsdk;
        devPython = pkgs.python313.withPackages (python-pkgs:
          with python-pkgs; [
            # Pinecone packages
            pinecone-client
            pinecone-plugin-inference
            pinecone-plugin-interface
            # Langsmith packages
            langsmith
            langchain-anthropic
            langchain-aws
            langchain-community
            langchain-openai
            langchain-perplexity
            langchain-core
            langchain-tests
            # System packages
            python-dotenv
            jupyter
            ipython
          ]);
      in {
        devShell = with pkgs;
          mkShell rec {
            ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            ANDROID_NDK_ROOT = "${androidSdk}/libexec/android-sdk/ndk-bundle";
            CMDLINE_TOOLS_ROOT = "${androidSdk}/libexec/android-sdk/cmdline-tools/8.0";
            JAVA_HOME = jdk17.home;
            FLUTTER_ROOT = flutter;
            DART_ROOT = "${flutter}/bin/cache/dart-sdk";
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVersion}/aapt2";
            QT_QPA_PLATFORM = "wayland;xcb"; # emulator related: try using wayland, otherwise fall back to X.
            # NB: due to the emulator's bundled qt version, it currently does not start with QT_QPA_PLATFORM="wayland".
            # Maybe one day this will be supported.

            # Android Emulator Performance Optimizations
            QEMU_OPTS = "-machine accel=kvm"; # Enable KVM hardware acceleration for faster emulation
            # Note: ANDROID_EMULATOR_USE_SYSTEM_LIBS is NOT set in NixOS as it conflicts with Nix store paths
            buildInputs = [
              flutter
              qemu_kvm
              gradle
              jdk17
              mesa-demos
              firebase-tools
              ffmpeg
              libsecret
              pkg-config
              # Custom environments
              devPython
              androidSdk
              gtk3
            ];
            # emulator related: vulkan-loader and libGL shared libs are necessary for hardware decoding
            LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [vulkan-loader libGL]}";
            # Globally installed packages, which are installed through `dart pub global activate package_name`,
            # are located in the `$PUB_CACHE/bin` directory.
            shellHook = ''
              # Dart/Flutter pub cache setup
              if [ -z "$PUB_CACHE" ]; then
                export PATH="$PATH:$HOME/.pub-cache/bin"
              else
                export PATH="$PATH:$PUB_CACHE/bin"
              fi

              # Add Android cmdline-tools to PATH for Flutter
              export PATH="$PATH:${androidSdk}/libexec/android-sdk/cmdline-tools/8.0/bin"

              # Add cmake to path
              export PATH="$(echo "$ANDROID_HOME/cmake/${cmakeVersion}".*/bin):$PATH"
            '';
          };
      }
    );
}
