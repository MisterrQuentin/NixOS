{
  pkgs,
  lib,
  username,
  config,
  host,
  ...
}: let
  inherit (import ./variables.nix) gitUsername gitEmail;
  myAliases = import ../../config/myAliases.txt;

  scriptContent = builtins.readFile ../../config/scripts.sh;
  scriptFile = pkgs.writeText "shell-functions.sh" scriptContent;

  # Modify this path if necessary to point to the correct location
  scriptDir = ../../config/dotlocalbin;

  nsxiv-fullscreen = pkgs.callPackage ./nsxiv-wrapper.nix {};
  # need to let mutt-wizard handle this file
  # mbsyncExtraConfig = builtins.readFile ../../config/mbsync-config.txt;
  pnpm = pkgs.nodePackages.pnpm;
  pythonConfigs = import ../../config/python.nix {inherit pkgs;};
in {
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "23.11";
  home.enableNixpkgsReleaseCheck = false;

  # Import Program Configurations
  imports = [
    ../../config/emoji.nix
    ../../config/fastfetch
    ../../config/hyprland.nix
    ../../config/yt-dlp.nix
    # ../../config/neovim.nix
    ../../config/neovim_josean.nix
    ../../config/tmux.nix
    ../../config/qutebrowser.nix
    ../../config/hn.nix
    ../../config/empty-dirs.nix
    ../../config/yazi.nix
    ../../config/plotbtc.nix
    ../../config/qute-keepassxc.nix
    ../../config/nostrudel.nix
    ../../config/rofi/rofi.nix
    ../../config/rofi/config-emoji.nix
    ../../config/rofi/config-long.nix
    ../../config/swaync.nix
    ../../config/waybar.nix
    ../../config/wlogout.nix
  ];

  # Place Files Inside Home Directory
  home.file = let
    scriptFiles = builtins.attrNames (builtins.readDir scriptDir);
    scriptEntries = builtins.listToAttrs (map
      (name: {
        name = ".local/bin/${name}";
        value = {
          source = "${scriptDir}/${name}";
          executable = true;
        };
      })
      scriptFiles);
  in
    scriptEntries
    // {
      ".config/mutt/mutt-wizard-stable.muttrc" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pkgs.mutt-wizard}/share/mutt-wizard/mutt-wizard.muttrc";
      };
      ".config/mutt/switch-stable.muttrc" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pkgs.mutt-wizard}/share/mutt-wizard/switch.muttrc";
      };
      ".config/mutt/gpg-wks-client-stable" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pkgs.mutt-wizard}/libexec/gpg-wks-client";
      };
      ".local/bin/setup-comfyui" = {
        executable = true;
        text = ''
          #!${pkgs.bash}/bin/bash

          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
            pkgs.stdenv.cc.cc.lib
            pkgs.linuxPackages.nvidia_x11
            pkgs.glib
            pkgs.gtk3
            pkgs.cudaPackages_12_4.cuda_cudart
            pkgs.libGL
            pkgs.xorg.libX11
            pkgs.xorg.libXrender
            pkgs.xorg.libXext
          ]}"
          export CUDA_PATH="${pkgs.cudaPackages_12_4.cuda_cudart}"
          export NVIDIA_DRIVER_CAPABILITIES="compute,utility"

          setup_environment() {
            echo "Setting up virtual environment..."
            rm -rf .venv
            ${pythonConfigs.comfyuiPython}/bin/python -m venv .venv
            source .venv/bin/activate
            pip install --upgrade pip
            pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
            pip install --no-cache-dir -r requirements.txt
            pip install --no-cache-dir pyyaml GitPython opencv-python imageio-ffmpeg
          }

          if [ ! -d "$HOME/ComfyUI" ]; then
            echo "Cloning ComfyUI repository..."
            ${pkgs.git}/bin/git clone https://github.com/comfyanonymous/ComfyUI.git "$HOME/ComfyUI"
            cd "$HOME/ComfyUI"
            setup_environment

            # Create directory structure
            ${pkgs.coreutils}/bin/mkdir -p models/{checkpoints,vae/mochi,diffusion_models/mochi,clip,t5}

            # Clone custom nodes
            cd custom_nodes
            ${pkgs.git}/bin/git clone https://github.com/ltdrdata/ComfyUI-Manager
            ${pkgs.git}/bin/git clone https://github.com/kijai/ComfyUI-MochiWrapper
            cd ..
          else
            cd "$HOME/ComfyUI"
          fi

          # Check if .venv exists and has the required packages
          if [ ! -d ".venv" ] || [ "$1" = "--force-setup" ]; then
            setup_environment
          fi

          source .venv/bin/activate
          python main.py
        '';
      };
      ".ssh/config".source = ../../config/ssh_config;
      ".config/hypr/pyprland.toml".source = ../../config/pyprland.toml;
      ".config/alacritty/alacritty.toml".source = ../../config/alacritty.toml;
      # "Pictures/Wallpapers" = {
      #   source = ../../config/wallpapers;
      #   recursive = true;
      # };
      ".config/wlogout/icons" = {
        source = ../../config/wlogout;
        recursive = true;
      };
      ".face.icon".source = ../../config/face.jpg;
      ".config/face.jpg".source = ../../config/face.jpg;
      ".config/zaney-wallpaper.jpg".source = ../../config/zaney-wallpaper.jpg;
      ".config/lazygit/config.yml".text = ''
        keybinding:
          universal:
            openDiffTool: d
            remove: D
      '';
      ".config/swappy/config".text = ''
        [Default]
        save_dir=/home/${username}/Pictures/Screenshots
        save_filename_format=swappy-%Y%m%d-%H%M%S.png
        show_panel=false
        line_size=5
        text_size=20
        text_font=Ubuntu
        paint_mode=brush
        early_exit=true
        fill_shape=false
      '';
      ".ollama/config".text = ''
        {
          "gpu": true
        }
      '';
      ".local/bin/restart-nextcloud-client.sh" = {
        text = ''
          #!/bin/sh
          sleep 60
          systemctl --user restart nextcloud-client.service
        '';
        executable = true;
      };
      ".config/mutt/muttrc_local".text = ''
        # common mutt definitions for all mailboxes
        # you can have up to 10 commands separated by -c:
        set editor = "nvim -c 'normal O' -c 'normal O' -c 'startinsert'"
        #set editor="nvim  \"+/^$/\" \"+nohl\" \"+ normal o\" \"+startinsert\"
        set date_format="%m/%d/%y %I:%M%p"
        set confirmappend = no
        set delete = yes
        set signature=~/.config/mutt/sig.txt
        #set signature = "python ~/Signature/Signature.py|"
        set text_flowed = yes

        macro index,pager A ";<save-message>=Archive\n" "move to Archive"
        macro index,pager d ";<save-message>=Trash<enter>" "move to Trash"
        # Reply to all recipients
        bind index,pager G group-reply
      '';

      ".config/mutt/sig.txt".text = ''
        "Paper is poverty, it is only the ghost of money, and not money itself."

        — Thomas Jefferson 1788
      '';
    };

  services.udiskie.enable = true;
  services.udiskie.tray = "always";

  # Ensure the ~/.config/Yubico directory exists
  home.activation = {
    createYubicoConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG /home/${username}/.config/Yubico
    '';
  };

  # Install & Configure Git
  programs.git = {
    enable = true;
    extraConfig = {
      diff.tool = "nvimdiff";
      difftool.nvimdiff.cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
    };
    userName = "${gitUsername}";
    userEmail = "${gitEmail}";
  };

  # programs.mbsync = {
  #   enable = true;
  #   extraConfig = mbsyncExtraConfig;
  # };

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = ["qutebrowser.desktop"];
      "x-scheme-handler/http" = ["qutebrowser.desktop"];
      "x-scheme-handler/https" = ["qutebrowser.desktop"];
      "x-scheme-handler/about" = ["qutebrowser.desktop"];
      "x-scheme-handler/unknown" = ["qutebrowser.desktop"];
      "text/x-shellscript" = ["nvim.desktop"];
      "text/x-script.python" = ["nvim.desktop"];
      "application/pdf" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
      "application/epub+zip" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
      "image/jpeg" = ["nsxiv-fullscreen.desktop"];
      "image/png" = ["nsxiv-fullscreen.desktop"];
      "text/plain" = ["nvim.desktop"];
      "text/markdown" = ["nvim.desktop"];
      "text/x-python" = ["nvim.desktop"];
      # Add more text-based MIME types as needed
    };
  };
  xdg.desktopEntries.nsxiv-fullscreen = {
    name = "NSXIV Fullscreen";
    genericName = "Image Viewer";
    exec = "${nsxiv-fullscreen}/bin/nsxiv-fullscreen %F";
    icon = "nsxiv";
    terminal = false;
    categories = ["Graphics" "Viewer"];
    mimeType = ["image/bmp" "image/gif" "image/jpeg" "image/jpg" "image/png" "image/tiff" "image/x-bmp" "image/x-portable-anymap" "image/x-portable-bitmap" "image/x-portable-graymap" "image/x-tga" "image/x-xpixmap"];
  };
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    comment = "Edit text files";
    exec = "nvim %F";
    icon = "nvim";
    mimeType = [
      "text/english"
      "text/x-makefile"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-java"
      "text/x-moc"
      "text/x-pascal"
      "text/x-tcl"
      "text/x-tex"
      "application/x-shellscript"
      "text/x-c"
      "text/x-c++"
      "text/plain"
      "text/x-markdown"
      "text/x-python"
      # Add more MIME types as needed
    ];
    categories = ["Utility" "TextEditor"];
    terminal = true;
    type = "Application";
  };

  xdg.configFile = {
    "nixpkgs/make-shell.nix".text = ''
      { pkgs ? import <nixpkgs> {} }: packages:
      pkgs.mkShell {
        buildInputs = with pkgs;
          [
            zsh
            neovim
          ]
          ++ packages;

          shellHook = builtins.readFile "/home/${username}/zaneyos/config/shell-script.sh";

        EDITOR = "nvim";
      }
    '';
    "mpv/mpv.conf" = {
      text = ''
        fs=yes
        sid=1
        sub-auto=fuzzy
        sub-file-paths=subtitles
        save-position-on-quit
      '';
    };
    "sc-im/scimrc" = {
      text = ''
        set autocalc
        set numeric
        set numeric_decimal=0
        set overlap
        set xlsx_readformulas
        set ignorecase=1

        nnoremap "<LEFT>" "fh"
        nnoremap "<RIGHT>" "fl"
        nnoremap "<UP>" "fk"
        nnoremap "<DOWN>" "fj"
        nnoremap "<C-e>" ":cellcolor A0 \"reverse=1 bold=1\"<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>"
        nnoremap "K" ":nextsheet <CR>"
        nnoremap "J" ":prevsheet <CR>"
        nnoremap "/" ":go into\"\"<LEFT>"

        REDEFINE_COLOR "WHITE" 248 248 242
        REDEFINE_COLOR "MAGENTA" 255 128 191
        #DEFINE_COLOR "comment" 121 112 169
        #DEFINE_COLOR "altbackground" 63 63 63
      '';
    };
    "newsboat/urls" = {
      source = ../../config/urls_newsboat; # Path to your existing CSS file
      target = "newsboat/urls";
    };

    "newsboat/config" = {
      text = ''
        show-read-feeds yes
        #auto-reload yes

        external-url-viewer "urlscan -dc -r 'linkhandler {}'"

        proxy-type socks5
        proxy 127.0.0.1:20170
        use-proxy no

        confirm-mark-feed-read no

        bind-key j down
        bind-key k up
        bind-key j next articlelist
        bind-key k prev articlelist
        bind-key J next-feed articlelist
        bind-key K prev-feed articlelist
        bind-key G end
        bind-key g home
        bind-key d pagedown
        bind-key u pageup
        bind-key l open
        bind-key h quit
        bind-key a toggle-article-read
        bind-key n next-unread
        bind-key N prev-unread
        bind-key D pb-download
        bind-key U show-urls
        bind-key x pb-delete

        color listnormal cyan default
        color listfocus black yellow standout bold
        color listnormal_unread blue default
        color listfocus_unread yellow default bold
        color info red black bold
        color article white default bold

        browser linkhandler
        macro , open-in-browser
        macro t set browser "qndl" ; open-in-browser ; set browser linkhandler
        macro a set browser "tsp youtube-dl --add-metadata -xic -f bestaudio/best" ; open-in-browser ; set browser linkhandler
        macro v set browser "setsid -f mpv" ; open-in-browser ; set browser linkhandler
        macro w set browser "lynx" ; open-in-browser ; set browser linkhandler
        macro d set browser "dmenuhandler" ; open-in-browser ; set browser linkhandler
        macro c set browser "echo %u | xclip -r -sel c" ; open-in-browser ; set browser linkhandler
        macro C set browser "youtube-viewer --comments=%u" ; open-in-browser ; set browser linkhandler
        macro p set browser "peertubetorrent %u 480" ; open-in-browser ; set browser linkhandler
        macro P set browser "peertubetorrent %u 1080" ; open-in-browser ; set browser linkhandler

        highlight all "---.*---" yellow
        highlight feedlist ".*(0/0))" black
        highlight article "(^Feed:.*|^Title:.*|^Author:.*)" cyan default bold
        highlight article "(^Link:.*|^Date:.*)" default default
        highlight article "https?://[^ ]+" green default
        highlight article "^(Title):.*$" blue default
        highlight article "\\[[0-9][0-9]*\\]" magenta default bold
        highlight article "\\[image\\ [0-9]+\\]" green default bold
        highlight article "\\[embedded flash: [0-9][0-9]*\\]" green default bold
        highlight article ":.*\\(link\\)$" cyan default
        highlight article ":.*\\(image\\)$" blue default
        highlight article ":.*\\(embedded flash\\)$" magenta default
      '';
    };
  };
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  # Styling Options
  stylix.targets = {
    yazi.enable = true;
    waybar.enable = false;
    rofi.enable = false;
    hyprland.enable = false;
    #hyprlock.enable = false; # Add this line
    tmux.enable = true;
    neovim.enable = true;
  };
  gtk = {
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      color-scheme = "prefer-dark"; # or "prefer-dark" if you want dark theme
    };
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "gtk3";
  };

  # Scripts
  home.packages = with pkgs; [
    (import ../../scripts/emopicker9000.nix {inherit pkgs;})
    (import ../../scripts/task-waybar.nix {inherit pkgs;})
    (import ../../scripts/squirtle.nix {inherit pkgs;})
    (import ../../scripts/nvidia-offload.nix {inherit pkgs;})
    (import ../../scripts/wallsetter.nix {
      inherit pkgs;
      inherit username;
    })
    (import ../../scripts/web-search.nix {inherit pkgs;})
    (import ../../scripts/rofi-launcher.nix {inherit pkgs;})
    (import ../../scripts/screenshootin.nix {inherit pkgs;})
    (import ../../scripts/list-hypr-bindings.nix {
      inherit pkgs;
      inherit host;
    })
    nsxiv
    nsxiv-fullscreen
    zsh-completions
    pythonConfigs.comfyuiPython
  ];

  services = {
    #   hypridle = {
    #     enable = true;
    #     settings = {
    #       general = {
    #         after_sleep_cmd = "hyprctl dispatch dpms on";
    #         ignore_dbus_inhibit = false;
    #         lock_cmd = "hyprlock";
    #       };
    #       listener = [
    #         {
    #           timeout = 900;
    #           on-timeout = "hyprlock";
    #         }
    #         {
    #           timeout = 1200;
    #           on-timeout = "hyprctl dispatch dpms off";
    #           on-resume = "hyprctl dispatch dpms on";
    #         }
    #       ];
    #     };
    #   };
    mpd = {
      enable = true;
      extraConfig = ''
        music_directory		"~/Music"
        #
        # auto_update "yes"
        # restore_paused "yes"
        # max_output_buffer_size "16384"

        audio_output {
                type            "pipewire"
                name            "PipeWire Sound Server"
        }

        audio_output {
               type	"fifo"
               name	"Visualizer feed"
               path	"/tmp/mpd.fifo"
               format	"44100:16:2"
        }
      '';
    };
  };

  # Optional: Configure Nextcloud client (let hyprland start it up)
  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  home.sessionVariables = {
    # PATH = "${pnpm}/bin:$HOME/.local/bin:$PATH";
    PATH = "$HOME/.local/bin:$PATH";
    DISABLE_AUTO_TITLE = "true";
    SUDO_EDITOR = "${pkgs.neovim}/bin/nvim";
    # EDITOR = "${pkgs.neovim}/bin/nvim";
    VISUAL = "${pkgs.neovim}/bin/nvim";
    PDFVIEWER = "${pkgs.zathura}/bin/zathura";
    TERMINAL = "${pkgs.kitty}/bin/kitty";
    TERMINAL_PROG = "${pkgs.kitty}/bin/kitty";
    DEFAULT_BROWSER = "${pkgs.qutebrowser}/bin/qutebrowser";
    BROWSER = "${pkgs.qutebrowser}/bin/qutebrowser";
    HISTSIZE = 1000000;
    SAVEHIST = 1000000;
    SYSTEMD_PAGER = "${pkgs.neovim}/bin/nvim";
    BAT_THEME = "Monokai Extended Origin";
    MANPAGER = "nvim +Man!";
  };

  systemd.user.startServices = true; # Add this at the same level as systemd.user.services
  systemd.user.services = {
    inotify = {
      Unit = {
        Description = "Monitor Nextcloud help directory for new files";
        After = ["network.target"];
      };

      Service = {
        ExecStart = "%h/.local/bin/notify_on_file_add.sh";
        Restart = "always";
        Environment = [
          "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
          "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus"
        ];
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };
  };

  programs = {
    zathura = {
      enable = true;
      options = {
        database = "sqlite";
      };
      extraConfig = ''
        set sandbox none
        set statusbar-h-padding 0
        set statusbar-v-padding 0
        set page-padding 1
        set selection-clipboard clipboard
        map u scroll half-up
        map d scroll half-down
        map D toggle_page_mode
        map r reload
        map R rotate
        map K zoom in
        map J zoom out
        map i recolor
        map p print
        map g goto top
        #set default-bg "rgba(255,255,255,0.3)"

        set adjust-open "best-fit"
        set default-bg "#1a1e2a" #00
        set default-fg "#F7F7F6" #01

        set statusbar-fg "#ffffff" #04
        set statusbar-bg "#1a1e2a" #01

        set highlight-color "#5294E2" #0A
        set highlight-active-color "#6A9FB5" #0D

        set notification-bg "#90A959" #0B
        set notification-fg "#151515" #00

        set guioptions none
        #set recolor "true"
        set recolor-lightcolor "#1a1e2a"
        set recolor-darkcolor "#ffffff"
        set recolor-keephue "true"
        set selection-clipboard clipboard

        #map p navigate previous
        #map n navigate next

      '';
    };
    zoxide.enable = true;
    tealdeer = {
      enable = true;
      settings = {
        updates = {
          auto_update = true;
        };
      };
    };
    gh.enable = true;
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
        rounded_corners = true;
        graph_symbol = "braille";
      };
      extraConfig = ''
        #* Starts bottom on a specified span or "full" (uses full span of monitor)
        #* Example: "left_right" (uses the two leftmost and rightmost quarters of the screen)
        #* or "1:2" (uses span 1 and 2)
        #* Default: "full"
        shown_spans="full"
      '';
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
      defaultOptions = [
        "--margin=15%"
        "--border=rounded"
        "--bind=ctrl-j:down,ctrl-k:up"
      ];
      fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
      fileWidgetOptions = ["--preview" "'bat -n --color=always --line-range :500 {}'"];
      changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
      changeDirWidgetOptions = ["--preview" "'eza --tree --color=always {} | head -200'"];
    };
    ncmpcpp = {
      enable = true;
      package = pkgs.ncmpcpp;
      settings = {
        # ncmpcpp_directory = "~/.config/ncmpcpp";
        lyrics_directory = "~/.local/share/lyrics";
        # mpd_music_dir = "/home/${username}/Music";
        message_delay_time = "1";
        # visualizer_type = "spectrum";
        song_list_format = "{$4%a - }{%t}|{$8%f$9}$R{$3(%l)$9}";
        song_status_format = "$b{{$8\"%t\"}} $3by {$4%a{ $3in $7%b{ (%y)}} $3}|{$8%f}";
        song_library_format = "{%n - }{%t}|{%f}";
        alternative_header_first_line_format = "$b$1$aqqu$/a$9 {%t}|{%f} $1$atqq$/a$9$/b";
        alternative_header_second_line_format = "{{$4$b%a$/b$9}{ - $7%b$9}{ ($4%y$9)}}|{%D}";
        current_item_prefix = "$(cyan)$r$b";
        current_item_suffix = "$/r$(end)$/b";
        current_item_inactive_column_prefix = "$(magenta)$r";
        current_item_inactive_column_suffix = "$/r$(end)";
        playlist_display_mode = "columns";
        browser_display_mode = "columns";
        progressbar_look = "->";
        media_library_primary_tag = "album_artist";
        media_library_albums_split_by_date = "no";
        startup_screen = "media_library";
        display_volume_level = "no";
        ignore_leading_the = "yes";
        external_editor = "nvim";
        use_console_editor = "yes";
        empty_tag_color = "magenta";
        main_window_color = "white";
        progressbar_color = "black:b";
        progressbar_elapsed_color = "blue:b";
        statusbar_color = "red";
        statusbar_time_color = "cyan:b";
        execute_on_song_change = "pkill -RTMIN+11 dwmblocks";
        execute_on_player_state_change = "pkill -RTMIN+11 dwmblocks";
      };
      bindings = [
        {
          key = "j";
          command = "scroll_down";
        }
        {
          key = "k";
          command = "scroll_up";
        }
        {
          key = "J";
          command = ["select_item" "scroll_down"];
        }
        {
          key = "K";
          command = ["select_item" "scroll_up"];
        }
        {
          key = "h";
          command = "previous_column";
        }
        {
          key = "l";
          command = "next_column";
        }

        {
          key = ".";
          command = "show_lyrics";
        }

        {
          key = "n";
          command = "next_found_item";
        }
        {
          key = "N";
          command = "previous_found_item";
        }

        # not used but bound
        {
          key = "J";
          command = "move_sort_order_down";
        }
        {
          key = "K";
          command = "move_sort_order_up";
        }
        {
          key = "h";
          command = "jump_to_parent_directory";
        }
        {
          key = "l";
          command = "enter_directory";
        }
        {
          key = "l";
          command = "run_action";
        }
        {
          key = "l";
          command = "play_item";
        }
        {
          key = "m";
          command = "show_media_library";
        }
        {
          key = "m";
          command = "toggle_media_library_columns_mode";
        }
        {
          key = "t";
          command = "show_tag_editor";
        }
        {
          key = "v";
          command = "show_visualizer";
        }
        {
          key = "G";
          command = "move_end";
        }
        {
          key = "g";
          command = "move_home";
        }
        {
          key = "U";
          command = "update_database";
        }
        {
          key = "s";
          command = "reset_search_engine";
        }
        {
          key = "s";
          command = "show_search_engine";
        }
        {
          key = "f";
          command = "show_browser";
        }
        {
          key = "f";
          command = "change_browse_mode";
        }
        {
          key = "x";
          command = "delete_playlist_items";
        }
        {
          key = "P";
          command = "show_playlist";
        }
      ];
    };
    kitty = {
      enable = true;
      package = pkgs.kitty;
      font.size = config.stylix.fonts.sizes.terminal;
      settings = {
        scrollback_lines = 10000;
        wheel_scroll_min_lines = 1;
        window_padding_width = 4;
        confirm_os_window_close = 0;
      };
      extraConfig = ''
        map alt+u open_url_with_hints
        map ctrl+shift+j scroll_line_down
        map ctrl+shift+k scroll_line_up
        map ctrl+shift+u scroll_page_up
        map ctrl+shift+d scroll_page_down
      '';
    };
    oh-my-posh = {
      enable = true;
      useTheme = "illusi0n";
      package = pkgs.oh-my-posh;
      enableZshIntegration = true;
    };
    # starship = {
    #        enable = true;
    #        package = pkgs.starship;
    # };
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      shellAliases = myAliases;
      oh-my-zsh = {
        enable = true;
        plugins = ["git"];
        #this theme is overridden by oh-my-posh, just leaving it here in case you remove oh-my-posh
        theme = "agnoster";
      };
      initExtra = ''
        # if [ -f "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" ]; then
        #   . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
        # fi
        source ${scriptFile}
        # Add zsh-completions to fpath
        fpath+=${pkgs.zsh-completions}/share/zsh/site-functions
        # PROMPT=" ◉ %U%F{magenta}%n%f%u@%U%F{blue}%m%f%u:%F{yellow}%~%f %F{green}→%f "
        bindkey -r '^l'
        bindkey -r '^g'
        bindkey -r '^[l'  # get rid of alt-L being "ls" from zsh-completions
        # Bind ALT-l and  ALT-y to the extract_urls function as per Luke Smith suckless terminal
        bindkey -s '^[l' 'extract_urls true\n'
        bindkey -s '^[y' 'extract_urls false\n'

        bindkey -s '^G' $'clear\r'
        eval "$(fzf --zsh)"
        # bindkey '^J' down-line-or-history
        # bindkey '^K' up-line-or-history
      '';
    };
    bash = {
      enable = true;
      enableCompletion = true;
      profileExtra = ''
        #if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        #  exec Hyprland
        #fi
      '';
      initExtra = ''
        source ${scriptFile}
        fastfetch
        if [ -f $HOME/.bashrc-personal ]; then
          source $HOME/.bashrc-personal
        fi
      '';
      shellAliases = {
        fr = "nh os switch --hostname ${host} /home/${username}/zaneyos";
        fu = "nh os switch --hostname ${host} --update /home/${username}/zaneyos";
        zu = "sh <(curl -L https://gitlab.com/Zaney/zaneyos/-/raw/main/install-zaneyos.sh)";
        ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
        v = "nvim";
        cat = "bat";
        ls = "eza --icons";
        ll = "eza -lh --icons --grid --group-directories-first";
        la = "eza -lah --icons --grid --group-directories-first";
        ".." = "cd ..";
      };
    };
    home-manager.enable = true;
    # hyprlock = {
    #   enable = true;
    #   settings = {
    #     general = {
    #       disable_loading_bar = true;
    #       grace = 10;
    #       hide_cursor = true;
    #       no_fade_in = false;
    #     };
    #     background = [
    #       {
    #         path = "/home/${username}/.config/zaney-wallpaper.jpg";
    #         blur_passes = 3;
    #         blur_size = 8;
    #       }
    #     ];
    #     image = [
    #       {
    #         path = "/home/${username}/.config/face.jpg";
    #         size = 350;
    #         border_size = 4;
    #         border_color = "rgb(0C96F9)";
    #         rounding = -1; # Negative means circle
    #         position = "0, 200";
    #         halign = "center";
    #         valign = "center";
    #       }
    #     ];
    #     input-field = [
    #       {
    #         size = "200, 50";
    #         position = "0, -80";
    #         monitor = "";
    #         dots_center = true;
    #         fade_on_empty = false;
    #         font_color = "rgb(CFE6F4)";
    #         inner_color = "rgb(657DC2)";
    #         outer_color = "rgb(0D0E15)";
    #         outline_thickness = 5;
    #         placeholder_text = "Password...";
    #         shadow_passes = 2;
    #       }
    #     ];
    #   };
    # };
  };
}
