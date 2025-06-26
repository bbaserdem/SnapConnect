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
            JAVA_HOME = jdk17.home;
            FLUTTER_ROOT = flutter;
            DART_ROOT = "${flutter}/bin/cache/dart-sdk";
            #GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/33.0.2/aapt2";
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
              android-studio
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
            '';
          };
      }
    );
}
