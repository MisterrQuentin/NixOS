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
in
  with lib; {
    # Home Manager Settings
    home.username = "${username}";
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "23.11";
    home.enableNixpkgsReleaseCheck = false;

    # Import Program Configurations
    imports = [
      ../../config/fastfetch
      ../../config/yt-dlp.nix
      # ../../config/neovim.nix
      ../../config/neovim_josean.nix
      ../../config/tmux.nix
      ../../config/qutebrowser.nix
      ../../config/hn.nix
      ../../config/empty-dirs.nix
      ../../config/yazi.nix
      ../../config/plotbtc.nix
      ../../config/nostrudel.nix
      # ../../config/rofi/rofi.nix
      # ../../config/rofi/config-emoji.nix
      # ../../config/rofi/config-long.nix
      # ../../config/swaync.nix
      # ../../config/waybar.nix
      # ../../config/wlogout.nix
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
        ".ssh/config".source = ../../config/ssh_config;
        ".config/hypr/pyprland.toml".source = ../../config/pyprland.toml;
        ".ollama/config".text = ''
          {
            "gpu": true
          }
        '';
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

    # Import Program Configurations
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;
      extraConfig = let
        modifier = "SUPER";
      in
        concatStrings [
          ''
                # /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  #
                # Sourcing external config files

                # Default Configs
                $configs = $HOME/.config/hypr/configs

                source=$configs/Settings.conf
                source=$configs/Keybinds.conf

                # User Configs
                $UserConfigs = $HOME/.config/hypr/UserConfigs

                source= $UserConfigs/Startup_Apps.conf
                source= $UserConfigs/ENVariables.conf
                source= $UserConfigs/Monitors.conf
                source= $UserConfigs/Laptops.conf
                source= $UserConfigs/LaptopDisplay.conf
                source= $UserConfigs/WindowRules.conf
                source= $UserConfigs/UserDecorAnimations.conf
                source= $UserConfigs/UserKeybinds.conf
                source= $UserConfigs/UserSettings.conf
                source= $UserConfigs/WorkspaceRules.conf

                # stuff from chris
                exec-once=[workspace 1 silent] kitty tmux
                exec-once=[workspace 2 silent] qutebrowser
                exec-once=[workspace 3 silent] ${pkgs.appimage-run}/bin/appimage-run /opt/appimages/simplex-desktop-x86_64.AppImage
                exec-once=[workspace 4 silent] ${pkgs.appimage-run}/bin/appimage-run /opt/appimages/session-desktop-linux-x86_64-1.14.2.AppImage
                input {
                #  kb_options = caps:ctrl_modifier
                  kb_options=ctrl:nocaps
                  touchpad {
                    disable_while_typing = true
                    natural_scroll = true
                    clickfinger_behavior = false
                    middle_button_emulation = true
                    tap-to-click = true
                    drag_lock = false
                  }
                  sensitivity = 2 # -1.0 - 1.0, 0 means no modification.
                }
              bind = ${modifier},Y,exec,pypr toggle yazi
              bind = ${modifier},M,exec,pypr toggle movies
              bind = ${modifier},B,exec,pypr toggle books
              bind = ${modifier},L,exec,pypr toggle llm
              bind = ${modifier},E,exec,pypr toggle mutt
              bind = ${modifier},N,exec,pypr toggle newsboat
            windowrulev2 = opacity 0.9 0.7, class:^(floorp)$
            windowrulev2 = workspace 2, class:^(qutebrowser)$
            windowrulev2 = workspace 3, class:^(floorp)$
            windowrulev2 = workspace 4, class:^(Session)$
            windowrulev2 = workspace 5, class:^(mpv)$
            windowrulev2 = workspace 6, class:^(org.keepassxc.KeePassXC)$
            windowrulev2 = workspace 7, class:^(QTodoTxt2)$
            windowrulev2 = workspace 8, class:^(org.pwmt.zathura)$
          ''
        ];
    };

    # Packages to install
    home.packages = with pkgs; [
      # (import ../../scripts/emopicker9000.nix {inherit pkgs;})
      # (import ../../scripts/task-waybar.nix {inherit pkgs;})
      # (import ../../scripts/squirtle.nix {inherit pkgs;})
      # (import ../../scripts/nvidia-offload.nix {inherit pkgs;})
      # (import ../../scripts/wallsetter.nix {
      #   inherit pkgs;
      #   inherit username;
      # })
      # (import ../../scripts/web-search.nix {inherit pkgs;})
      # (import ../../scripts/rofi-launcher.nix {inherit pkgs;})
      # (import ../../scripts/screenshootin.nix {inherit pkgs;})
      # (import ../../scripts/list-hypr-bindings.nix {
      #   inherit pkgs;
      #   inherit host;
      # })
      # nsxiv
      # nsxiv-fullscreen
      zsh-completions
    ];
    # Ensure the ~/.config/Yubico directory exists
    home.activation = {
      createYubicoConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p $VERBOSE_ARG /home/${username}/.config/Yubico
      '';
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

    programs = {
      # Let Home Manager install and manage itself.
      home-manager.enable = true;

      # Install & Configure Git
      git = {
        enable = true;
        userName = "${gitUsername}";
        userEmail = "${gitEmail}";
      };

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
      zsh = {
        enable = true;
        enableCompletion = true;
        oh-my-zsh = {
          enable = true;
          plugins = ["git"];
          theme = "xiong-chiamiov-plus";
        };
        shellAliases = myAliases;

        enableAutosuggestions = true;
        syntaxHighlighting.enable = true;

        initExtra = ''
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
    };
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
  }
