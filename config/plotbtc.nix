{
  config,
  pkgs,
  lib,
  ...
}: {
  home.activation.check-plotbtc-repo = lib.hm.dag.entryAfter ["writeBoundary"] ''
    REPO_DIR="$HOME/plotbtc"
    
    if [ ! -d "$REPO_DIR" ]; then
      echo "Triggering initial clone of plotbtc repository..."
      # Create trigger file if directory doesn't exist
      touch "$HOME/.plotbtc-needs-clone"
    fi
  '';

  systemd.user.services.clone-plotbtc = {
    Unit = {
      Description = "Automatic plotbtc repository management";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
    };

    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "clone-plotbtc-service" ''
        set -euo pipefail
        export PATH=${lib.makeBinPath [pkgs.git pkgs.coreutils pkgs.curl]}
        export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

        REPO_URL="https://github.com/bimmerr2019/plotbtc.git"
        REPO_DIR="$HOME/plotbtc"
        
        # Check for first-time setup
        if [[ -f "$HOME/.plotbtc-needs-clone" ]]; then
          echo "Performing initial clone..."
          git clone "$REPO_URL" "$REPO_DIR"
          rm -f "$HOME/.plotbtc-needs-clone"
        fi

        # Update existing repo if it exists
        if [[ -d "$REPO_DIR" ]]; then
          echo "Updating existing repository..."
          git -C "$REPO_DIR" pull
        fi
      '';
      Restart = "on-failure";
      RestartSec = "30s";
    };

    Install.WantedBy = ["default.target"];
    Unit.StartLimitIntervalSec = "300";
    Unit.StartLimitBurst = 5;
  };
}

