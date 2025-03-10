{
  username,
  pkgs,
  lib,
  ...
}: let
  # Create a custom Python environment with pynacl
  qbPythonEnv = pkgs.python3.withPackages (ps: [
    ps.pynacl # Add pynacl to the environment
  ]);

  # Create a wrapped qutebrowser that uses our custom Python environment
  customQutebrowser = pkgs.qutebrowser.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs or [] ++ [pkgs.makeWrapper];
    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        wrapProgram "$out/bin/qutebrowser" \
          --prefix PATH : "${qbPythonEnv}/bin" \
          --prefix PYTHONPATH : "${qbPythonEnv}/${qbPythonEnv.sitePackages}"
      '';
  });
in {
  # Install the custom wrapped qutebrowser
  home.packages = with pkgs; [customQutebrowser];

  # Configure qutebrowser to use the custom package
  programs.qutebrowser = {
    enable = true;
    package = customQutebrowser; # Use our wrapped version

    settings = {
      colors.webpage = {
        darkmode.enabled = true;
        preferred_color_scheme = "dark";
      };
      content = {
        javascript = {
          enabled = true;
          clipboard = "access-paste";
        };
        local_content_can_access_file_urls = true;
        local_content_can_access_remote_urls = true;
      };
      downloads = {
        location.directory = "/home/${username}/Downloads";
        remove_finished = 20000;
      };
      fileselect = {
        handler = "external";
        multiple_files.command = [
          "alacritty"
          "-e"
          "yazi"
          "--chooser-file={}"
        ];
        single_file.command = [
          "alacritty"
          "-e"
          "yazi"
          "--chooser-file={}"
        ];
      };
      fonts = {
        default_size = lib.mkForce "16pt";
        hints = "bold 16px default_family";
      };
      url = {
        default_page = "about:blank";
        start_pages = ["https://app.daily.dev/"];
      };
      window.transparent = true;
      zoom.default = "100%";
    };

    searchEngines = {
      DEFAULT = "https://lili2023.dedyn.io/?q={}";
      a = "https://www.amazon.com/s?k={}";
      aw = "https://wiki.archlinux.org/?search={}";
      re = "https://old.reddit.com/r/{}";
      ub = "https://urbandictionary.com/define.php?term={}";
      yt = "http://localhost:3000/results?search_query={}";
      ww = "https://en.wikipedia.org/?search={}";
      tpb = "http://thepiratebay.org/search/{}";
      eb = "http://ebay.com/sch/{}";
      ddg = "http://duckduckgo.com/?q={}";
      star = "https://github.com/stars?utf8=%E2%9C%93&q={}";
      so = "https://google.com/search?q=site:stackoverflow.com {}";
      gl = "http://www.google.com/search?q={}&btnI=Im+Feeling+Lucky";
      ghi = "https://github.com/{}/issues";
      wa = "http://www.wolframalpha.com/input/?i={}";
      ha = "https://google.com/search?q=site:hackage.haskell.org {}";
      gamedev = "http://gamedev.stackexchange.com/search?q={}";
      npm = "https://npmjs.org/search?q={}";
      cargo = "https://crates.io/search?q={}";
      zen = "http://brandalliance.zendesk.com/search?query={}";
      g = "https://www.google.com/search?q={}";
      st = "https://yifysubtitles.ch/search?q={}";
      alert = "http://alrt.io/{}";
      hackage = "http://hackage.haskell.org/package/{}";
      travis = "https://travis-ci.org/{}";
      ttx = "https://testnet.smartbit.com.au/tx/{}/";
      e = "https://www.google.com/search?q=site%3Apackage.elm-lang.org+{}&btnI=Im+Feeling+Lucky";
      key = "https://www.npmjs.org/browse/keyword/{}";
      h = "http://holumbus.fh-wedel.de/hayoo/hayoo.html?query={}";
      hoogle = "http://www.haskell.org/hoogle/?hoogle={}";
      github = "http://github.com/search?q={}";
      ph = "http://phind.com/search?q={}";
      ai = "https://chat.openai.com/chat?q={}";
      ba = "http://blockstream.info/address/{}";
      bgg = "http://www.boardgamegeek.com/metasearch.php?searchtype=game&search={}";
      pgp = "http://pgp.mit.edu/pks/lookup?search={}&op=index";
      gh = "https://github.com/{}";
      cd = "https://docs.rs/{}/latest";
      crate = "https://crates.io/crates/{}";
      repo = "http://npmrepo.com/{}";
      ec = "http://package.elm-lang.org/packages/elm-lang/{}/latest";
      btx = "https://blockstream.info/tx/{}";
    };

    keyBindings = {
      normal = {
        "mm" = "hint links spawn /etc/profiles/per-user/${username}/bin/yt-dlp {hint-url}";
        "P" = "hint links spawn mpv {hint-url} --no-video";
        "xx" = "config-cycle statusbar.show never always;; config-cycle tabs.show never always";
        "K" = "tab-next";
        "J" = "tab-prev";
        "<Alt-k>" = "tab-next";
        "<Alt-j>" = "tab-prev";
        "pw" = "spawn --userscript qute-keepassxc --key A5FB81C665B0B50394F9D65208E06F737783EA38";
      };
      insert = {
        "<Alt-Shift-u>" = "spawn --userscript qute-keepassxc --key A5FB81C665B0B50394F9D65208E06F737783EA38";
      };
    };

    extraConfig = ''
      # Other extra configurations...
      config.unbind("m")
    '';
  };

  # Manage the quickmarks file
  home.file.".config/qutebrowser/quickmarks".source = ./quickmarks;
}
