{
  pkgs,
  lib,
  ...
}: {
  home.activation.quteKeepassxcDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Always create directory and symlink (safe operation)
    mkdir -p "$HOME/.local/share/qutebrowser/userscripts"
    ln -sfn "$HOME/qute-keepassxc/qute-keepassxc" "$HOME/.local/share/qutebrowser/userscripts/qute-keepassxc" || true
  '';

  systemd.user.services.qute-keepassxc-setup = {
    Unit = {
      Description = "qute-keepassxc repository management";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
      # Prevent blocking HM activation
      RefuseManualStart = false;
    };

    Service = let
      envPath = lib.makeBinPath [ pkgs.git pkgs.curl pkgs.coreutils pkgs.iputils ];
    in {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "qute-keepassxc-setup" ''
        set -euo pipefail
        export PATH="${envPath}"
        export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

        REPO_URL="https://github.com/ususdei/qute-keepassxc"
        REPO_DIR="$HOME/qute-keepassxc"

        # Network check with 1 minute timeout
        timeout 60 ${pkgs.bash}/bin/bash -c "
          until ${pkgs.curl}/bin/curl -Is https://github.com >/dev/null || ${pkgs.iputils}/bin/ping -c 1 -W 3 github.com;
          do sleep 2;
          done"

        # Repository operations with error containment
        if [[ -d "$REPO_DIR" ]]; then
          if ! ${pkgs.git}/bin/git -C "$REPO_DIR" pull; then
            echo "Pull failed - attempting fresh clone..."
            rm -rf "$REPO_DIR"
            ${pkgs.git}/bin/git clone "$REPO_URL" "$REPO_DIR"
          fi
        else
          ${pkgs.git}/bin/git clone "$REPO_URL" "$REPO_DIR"
        fi

        chmod +x "$REPO_DIR/qute-keepassxc" || true
      '';
      # Prevent restart storms
      Restart = "no";
      TimeoutStartSec = "90s";
    };

    Install.WantedBy = [ "default.target" ];
  };

  # Add critical systemd security settings
  systemd.user.services."home-manager-bimmer" = {
    Service = {
      TimeoutStartSec = "5min";
      Restart = "no";
    };
  };
}

