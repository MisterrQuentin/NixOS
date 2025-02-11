final: prev: {
  calibre = prev.calibre.overrideAttrs (oldAttrs: {
    doCheck = false;
    doInstallCheck = false;
    checkPhase = "true";
    installCheckPhase = "true";
  });
  tmuxPlugins =
    prev.tmuxPlugins
    // {
      resurrect = prev.tmuxPlugins.resurrect.overrideAttrs (oldAttrs: {
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            # Remove broken symlinks causing build failures
            rm -f "$out/share/tmux-plugins/resurrect/run_tests"
            rm -f "$out/share/tmux-plugins/resurrect/tests/run_tests_in_isolation"
            rm -f "$out/share/tmux-plugins/resurrect/tests/helpers/helpers.sh"
          '';
      });
    };

  # tmuxPlugins.resurrect = prev.tmuxPlugins.resurrect.overrideAttrs (old: {
  #   postInstall =
  #     old.postInstall
  #     + ''
  #       # Remove the broken symlinks
  #       rm -f ${old.package.out}/share/tmux-plugins/resurrect/run_tests
  #       rm -f ${old.package.out}/share/tmux-plugins/resurrect/tests/run_tests_in_isolation
  #       rm -f ${old.package.out}/share/tmux-plugins/resurrect/tests/helpers/helpers.sh
  #
  #       # Optional: Recreate the symlinks to the correct paths if necessary
  #       # ln -s ${old.package.out}/share/tmux-plugins/resurrect/lib/tmux-test/run_tests ${old.package.out}/share/tmux-plugins/resurrect/run_tests
  #       # ln -s ${old.package.out}/share/tmux-plugins/resurrect/lib/tmux-test/tests/run_tests_in_isolation ${old.package.out}/share/tmux-plugins/resurrect/tests/run_tests_in_isolation
  #       # ln -s ${old.package.out}/share/tmux-plugins/resurrect/lib/tmux-test/tests/helpers/helpers.sh ${old.package.out}/share/tmux-plugins/resurrect/tests/helpers/helpers.sh
  #     '';
  # });

  eslint = prev.eslint.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        if [ -d "$out/lib/node_modules/eslint/packages/eslint-config-eslint" ]; then
          ln -sfn $out/lib/node_modules/eslint/packages/eslint-config-eslint \
                 $out/lib/node_modules/eslint/node_modules/
        fi
      '';
  });

  signal-desktop = prev.stdenv.mkDerivation rec {
    pname = "signal-desktop";
    version = "7.41.0";

    src = prev.fetchurl {
      url = "https://updates.signal.org/desktop/apt/pool/s/signal-desktop/signal-desktop_${version}_amd64.deb";
      sha256 = "sha256-wBbJH7/QP12JLaDw6LuFkfsUCqoDwYYlcEcQ9yGkNqo=";
    };

    nativeBuildInputs = with prev; [
      dpkg
      makeWrapper
      wrapGAppsHook
      autoPatchelfHook
    ];

    buildInputs = with prev; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libnotify
      libpulseaudio
      libsecret
      libuuid
      libxkbcommon
      mesa
      nspr
      nss
      pango
      systemd
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libxcb
      xorg.libxshmfence
      zlib
    ];

    runtimeDependencies = with prev; [
      (lib.getLib systemd)
      libnotify
      libpulseaudio
      libsecret
    ];

    unpackPhase = ''
      dpkg-deb -x $src .
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      cp -R opt/Signal $out/lib/Signal

      mkdir -p $out/bin
      makeWrapper $out/lib/Signal/signal-desktop $out/bin/signal-desktop \
        --prefix PATH : ${prev.lib.makeBinPath [prev.xdg-utils]} \
        --prefix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath buildInputs} \
        --set NIXOS_OZONE_WL 1

      mkdir -p $out/share
      cp -R usr/share/applications $out/share
      cp -R usr/share/icons $out/share

      # Fix the desktop file
      substituteInPlace $out/share/applications/signal-desktop.desktop \
        --replace "/opt/Signal/signal-desktop" "$out/bin/signal-desktop"

      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Private messaging from your desktop";
      homepage = "https://signal.org/";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [];
      platforms = ["x86_64-linux"];
    };
  };
}
