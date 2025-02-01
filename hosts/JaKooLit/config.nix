# Main default config
{
  config,
  pkgs,
  host,
  username,
  options,
  lib,
  inputs,
  system,
  ...
}: let
  inherit (import ./variables.nix) keyboardLayout;
  python-packages = pkgs.python3.withPackages (
    ps:
      with ps; [
        requests
        pyquery # needed for hyprland-dots Weather script
      ]
  );
in {
  imports = [
    ./hardware.nix
    ./users.nix
    # ../../modules_ja/amd-drivers.nix
    # ../../modules_ja/nvidia-drivers.nix
    # ../../modules_ja/nvidia-prime-drivers.nix
    # ../../modules_ja/intel-drivers.nix
    ../../modules/nvidia-drivers.nix
    ../../modules_ja/vm-guest-services.nix
    ../../modules_ja/local-hardware-clock.nix
  ];

  # BOOT related stuff
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;

    kernelParams = [
      "systemd.mask=systemd-vconsole-setup.service"
      "systemd.mask=dev-tpmrm0.device" #this is to mask that stupid 1.5 mins systemd bug
      "nowatchdog"
      "modprobe.blacklist=sp5100_tco" #watchdog for AMD
      "modprobe.blacklist=iTCO_wdt" #watchdog for Intel
    ];

    # This is for OBS Virtual Cam Support
    kernelModules = ["v4l2loopback"];
    extraModulePackages = [config.boot.kernelPackages.v4l2loopback];

    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = [];
    };

    # Needed For Some Steam Games
    #kernel.sysctl = {
    #  "vm.max_map_count" = 2147483642;
    #};

    ## BOOT LOADERS: NOT USE ONLY 1. either systemd or grub
    # Bootloader SystemD
    loader.systemd-boot.enable = true;

    loader.efi = {
      #efiSysMountPoint = "/efi"; #this is if you have separate /efi partition
      canTouchEfiVariables = true;
    };

    loader.timeout = 1;

    # Bootloader GRUB
    #loader.grub = {
    #enable = true;
    #  devices = [ "nodev" ];
    #  efiSupport = true;
    #  gfxmodeBios = "auto";
    #  memtest86.enable = true;
    #  extraGrubInstallArgs = [ "--bootloader-id=${host}" ];
    #  configurationName = "${host}";
    #	 };

    # Bootloader GRUB theme, configure below

    ## -end of BOOTLOADERS----- ##

    # Make /tmp a tmpfs
    tmp = {
      useTmpfs = false;
      tmpfsSize = "30%";
    };

    # Appimage Support
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };

    plymouth.enable = true;
  };
  #Put appImages in the /opt diretory:
  # Create /opt/appimages directory
  system.activationScripts = {
    createAppImageDir = ''
      mkdir -p /opt/appimages
      chown root:users /opt/appimages
      chmod 775 /opt/appimages
    '';
  };

  # GRUB Bootloader theme. Of course you need to enable GRUB above.. duh!
  #distro-grub-themes = {
  #  enable = true;
  #  theme = "nixos";
  #};

  # Add this section to set the permissions for the tuigreet cache directory
  system.activationScripts.tuigreet-permissions = ''
    mkdir -p /var/cache/tuigreet
    chmod 777 /var/cache/tuigreet
  '';

  # Extra Module Options
  # drivers.amdgpu.enable = false;
  # drivers.intel.enable = false;
  drivers.nvidia.enable = true;
  # drivers.nvidia-prime = {
  #   enable = false;
  #   intelBusID = "";
  #   nvidiaBusID = "";
  # };
  vm.guest-services.enable = false;
  local.hardware-clock.enable = false;

  # networking
  networking.networkmanager.enable = true;
  networking.hostName = "${host}";
  networking.timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];

  # Set your time zone.
  time.timeZone = "America/Phoenix";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  nixpkgs.overlays = [
    (import ../../config/overlays.nix)
  ];

  nixpkgs.config.allowUnfree = true;

  programs = {
    # hyprland = {
    #   enable = true;
    #   package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland; #hyprland-git
    #   portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland; # xdphls
    #   xwayland.enable = true;
    # };

    waybar.enable = true;
    hyprlock.enable = true;
    # firefox.enable = true;
    git.enable = true;
    nm-applet.indicator = true;
    #neovim.enable = true;

    thunar.enable = true;
    thunar.plugins = with pkgs.xfce; [
      exo
      mousepad
      thunar-archive-plugin
      thunar-volman
      tumbler
    ];

    virt-manager.enable = true;

    #steam = {
    #  enable = true;
    #  gamescopeSession.enable = true;
    #  remotePlay.openFirewall = true;
    #  dedicatedServer.openFirewall = true;
    #};

    xwayland.enable = true;

    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
  # environment.shells = with pkgs; [zsh];

  users = {
    mutableUsers = true;
  };

  environment.systemPackages =
    (with pkgs; [
      # System Packages
      baobab
      btrfs-progs
      clang
      curl
      cpufrequtils
      duf
      eza
      nh
      fzf
      ffmpeg
      glib #for gsettings to work
      gsettings-qt
      git
      killall
      libappindicator
      libnotify
      openssl #required by Rainbow borders
      pciutils
      vim
      wget
      xdg-user-dirs
      xdg-utils
      zsh-completions
      nix-zsh-completions
      libvirt
      virt-viewer
      virt-manager
      hplip

      calibre
      signal-desktop
      freetube
      newsboat
      zathura
      ncmpcpp
      termusic
      ytermusic
      wireguard-tools
      floorp

      # fastfetch
      (mpv.override {scripts = [mpvScripts.mpris];}) # with tray
      #ranger

      # Hyprland Stuff
      (ags.overrideAttrs (oldAttrs: {
        inherit (oldAttrs) pname;
        version = "1.8.2";
      }))
      #ags
      btop
      brightnessctl # for brightness control
      # cava
      #cliphist
      eog
      gnome-system-monitor
      file-roller
      grim
      gtk-engine-murrine #for gtk themes
      hyprcursor # requires unstable channel
      hypridle # requires unstable channel
      imagemagick
      inxi
      jq
      bat
      kitty
      libsForQt5.qtstyleplugin-kvantum #kvantum
      networkmanagerapplet
      nwg-look # requires unstable channel
      nvtopPackages.full
      pamixer
      pavucontrol
      playerctl
      polkit_gnome
      pyprland
      libsForQt5.qt5ct
      qt6ct
      qt6.qtwayland
      qt6Packages.qtstyleplugin-kvantum #kvantum
      rofi-wayland
      slurp
      swappy
      swaynotificationcenter
      swww
      unzip
      wallust
      wl-clipboard
      wlogout
      yad
      yt-dlp

      #phone (flash the phone and get adb so can send files):
      android-udev-rules
      android-tools

      # neomutt and related progs:
      neomutt
      isync
      msmtp
      mypy
      ruff
      mutt-wizard
      pass
      notmuch
      imagemagick
      w3m
      lynx
      abook

      # Yubikey
      gnupg
      yubikey-personalization
      yubikey-manager
      pcsclite
      pcsctools
      pam_u2f
      keepassxc

      ripgrep
      ripgrep-all

      appimage-run
      # Optionally, add a convenient way to run AppImages
      (writeShellScriptBin "run-appimage" ''
        ${appimage-run}/bin/appimage-run /opt/appimages/$1
      '')
      (writeScriptBin "music-layout" ''
        #!${pkgs.bash}/bin/bash

        # Create new window or use existing one
        tmux new-window -n music || tmux select-window -t music

        # Split the window vertically into 3 panes
        tmux split-window -v
        tmux split-window -h

        # Select and run command in each pane
        tmux select-pane -t 0
        tmux send-keys "ncmpcpp -s media_library" C-m

        tmux select-pane -t 1
        tmux send-keys "ncmpcpp -s playlist_editor" C-m

        tmux select-pane -t 2
        tmux send-keys "ncmpcpp -s playlist" C-m
      '')

      # Wireguard control:
      (writeScriptBin "wg-toggle" ''
        #!${stdenv.shell}
        WG_DIR="/etc/nixos/wireguard"

        # Check if running as root
        if [ "$(id -u)" -ne 0 ]; then
          exec sudo "$0" "$@"
        fi

        # Check if wireguard directory exists
        if [ ! -d "$WG_DIR" ]; then
          echo "Error: Wireguard directory ($WG_DIR) does not exist."
          echo "Please create the directory and add your configuration files."
          exit 1
        fi

        # Check if directory is empty (no .conf files)
        if [ -z "$(find "$WG_DIR" -name "*.conf" 2>/dev/null)" ]; then
          echo "Error: No Wireguard configuration files found in $WG_DIR"
          echo "Please add your .conf files to the directory."
          exit 1
        fi

        # Function to get current running interface (if any)
        get_running_interface() {
          wg show interfaces 2>/dev/null
        }

        # If WireGuard is running, just turn it off
        RUNNING_INTERFACE=$(get_running_interface)
        if [ -n "$RUNNING_INTERFACE" ]; then
          CONFIG="$WG_DIR/$RUNNING_INTERFACE.conf"
          wg-quick down "$CONFIG"
          echo "WireGuard disconnected"
          exit 0
        fi

        # If we get here, WireGuard is not running, so show the menu
        echo "Select WireGuard configuration to activate:"

        # Create array of config files
        configs=()
        while IFS= read -r -d $'\0' file; do
          configs+=("$file")
        done < <(find "$WG_DIR" -name "*.conf" -print0 | sort -z)

        # Display menu
        i=1
        for config in "''${configs[@]}"; do
          filename=$(basename "$config" .conf)
          echo "$i) $filename"
          ((i++))
        done

        # Get user choice
        read -p "Enter number (1-$((i-1))): " choice

        # Validate input
        if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $((i-1)) ]; then
          echo "Invalid selection"
          exit 1
        fi

        # Convert choice to array index (0-based)
        ((choice--))

        # Get selected config file
        selected_config="''${configs[$choice]}"

        # Extract interface name from filename
        INTERFACE=$(basename "$selected_config" .conf)

        # Activate the selected configuration
        wg-quick up "$selected_config"
        echo "WireGuard connected using $INTERFACE"
      '')

      # Add a desktop file for each appimage here:
      (makeDesktopItem {
        name = "Nunchuk";
        desktopName = "Nunchuk";
        exec = "${pkgs.appimage-run}/bin/appimage-run /opt/appimages/nunchuk-linux-1.9.39.AppImage";
        icon = ""; # Leave empty if there's no icon
        comment = "Nunchuk Application";
        categories = ["Utility"];
        terminal = false;
      })
      (makeDesktopItem {
        name = "Session";
        desktopName = "Session";
        exec = "${pkgs.appimage-run}/bin/appimage-run /opt/appimages/session-desktop-linux-x86_64-1.14.2.AppImage";
        icon = ""; # Leave empty if there's no icon
        comment = "Session Application";
        categories = ["Utility"];
        terminal = false;
      })
      (makeDesktopItem {
        name = "SimpleX";
        desktopName = "SimpleX";
        exec = "${pkgs.appimage-run}/bin/appimage-run /opt/appimages/simplex-desktop-x86_64.AppImage";
        icon = ""; # Leave empty if there's no icon
        comment = "SimpleX Application";
        categories = ["Utility"];
        terminal = false;
      })
      (makeDesktopItem {
        name = "LMStudio";
        desktopName = "LM Studio";
        exec = "${pkgs.appimage-run}/bin/appimage-run /opt/appimages/LM-Studio-0.3.9.AppImage";
        icon = ""; # Leave empty if there's no icon
        comment = "LM Studio Application";
        categories = ["Utility"];
        terminal = false;
      })
      (makeDesktopItem {
        name = "Logseq";
        desktopName = "Logseq";
        exec = "${pkgs.appimage-run}/bin/appimage-run /opt/appimages/Logseq-linux-x64-0.10.9.AppImage";
        icon = ""; # Leave empty if there's no icon
        comment = "Logseq Application";
        categories = ["Utility"];
        terminal = false;
      })

      #waybar  # if wanted experimental next line
      #(pkgs.waybar.overrideAttrs (oldAttrs: { mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];}))
    ])
    ++ [
      python-packages
    ];

  # FONTS
  fonts.packages = with pkgs; [
    noto-fonts
    fira-code
    noto-fonts-cjk-sans
    jetbrains-mono
    font-awesome
    terminus_font
    nerd-fonts.jetbrains-mono
  ];

  # Extra Portal Configuration
  xdg.portal = {
    enable = true;
    wlr.enable = false;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
  };

  # Services to start
  services = {
    printing.enable = true;
    printing.drivers = [pkgs.hplip];
    printing.startWhenNeeded = true; # optional
    xserver = {
      enable = false;
      xkb = {
        layout = "${keyboardLayout}";
        variant = "";
      };
    };
    # Enable ollama
    ollama = {
      enable = true;
      port = 11434;
      # Add these lines to ensure GPU support
    };

    greetd = {
      enable = true;
      vt = 3;
      settings = {
        default_session = {
          # user = username;
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland"; # start Hyprland with a TUI login manager
        };
      };
    };

    smartd = {
      enable = false;
      autodetect = true;
    };

    gvfs.enable = true;
    tumbler.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    udev.enable = true;
    envfs.enable = true;
    dbus.enable = true;

    fstrim = {
      enable = true;
      interval = "weekly";
    };

    libinput.enable = true;

    rpcbind.enable = false;
    nfs.server.enable = false;

    openssh.enable = true;
    flatpak.enable = false;

    blueman.enable = true;

    #hardware.openrgb.enable = true;
    #hardware.openrgb.motherboard = "amd";

    fwupd.enable = true;

    upower.enable = true;

    gnome.gnome-keyring.enable = true;

    #printing = {
    #  enable = false;
    #  drivers = [
    # pkgs.hplipWithPlugin
    #  ];
    #};

    #avahi = {
    #  enable = true;
    #  nssmdns4 = true;
    #  openFirewall = true;
    #};

    #ipp-usb.enable = true;

    #syncthing = {
    #  enable = false;
    #  user = "${username}";
    #  dataDir = "/home/${username}";
    #  configDir = "/home/${username}/.config/syncthing";
    #};
  };

  systemd.services.flatpak-repo = {
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # zram
  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 30;
    swapDevices = 1;
    algorithm = "zstd";
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  #hardware.sane = {
  #  enable = true;
  #  extraBackends = [ pkgs.sane-airscan ];
  #  disabledDefaultBackends = [ "escl" ];
  #};

  # Extra Logitech Support
  hardware.logitech.wireless.enable = false;
  hardware.logitech.wireless.enableGraphical = false;

  # Bluetooth
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;

  # Security / Polkit
  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("users")
          && (
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          )
        )
      {
        return polkit.Result.YES;
      }
    })
  '';
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # Cachix, Optimization settings and garbage collection automation
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Virtualization / Containers
  virtualisation.libvirtd.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # OpenGL
  hardware.graphics = {
    enable = true;
  };

  console.keyMap = "${keyboardLayout}";

  # For Electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
