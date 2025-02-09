{ pkgs, lib, ... }:
let
  nodejs = pkgs.nodejs_20;
  pnpm = pkgs.nodePackages.pnpm;
  envPath = lib.makeBinPath [ pkgs.git pkgs.curl nodejs pnpm pkgs.coreutils ];
in
{
  home.packages = with pkgs; [ nodejs pnpm go ];

  systemd.user.services.setup-nostrudel = {
    Unit = {
      Description = "Nostrudel repository management";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      ConditionPathExists = "!%h/nostrudel/.setup-complete";
    };

    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "setup-nostrudel-service" ''
        set -euo pipefail
        export PATH="${envPath}"
        export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

        REPO_DIR="$HOME/nostrudel"
        REPO_URL="https://github.com/hzrd149/nostrudel.git"

        # Network check with retries
        check_network() {
          ${pkgs.curl}/bin/curl -Is https://github.com | ${pkgs.gnugrep}/bin/grep -q "HTTP/.* 200"
        }

        max_attempts=30
        for attempt in $(seq 1 $max_attempts); do
          if check_network; then break; fi
          if [ $attempt -eq $max_attempts ]; then exit 1; fi
          sleep 5
        done

        # Repository management
        if [ -d "$REPO_DIR" ]; then
          ${pkgs.git}/bin/git -C "$REPO_DIR" pull || {
            echo "Pull failed - recloning..."
            rm -rf "$REPO_DIR"
            ${pkgs.git}/bin/git clone "$REPO_URL" "$REPO_DIR"
          }
        else
          ${pkgs.git}/bin/git clone "$REPO_URL" "$REPO_DIR"
        fi

        # Dependency installation
        cd "$REPO_DIR"
        for retry in $(seq 1 3); do
          ${pnpm}/bin/pnpm install --frozen-lockfile && break
          sleep 10
        done

        touch "$REPO_DIR/.setup-complete"
      '';
      Restart = "on-failure";
      RestartSec = "30s";
    };

    Install.WantedBy = [ "default.target" ];
  };

  home.file.".local/bin/nostr" = {
    text = ''
      #!/usr/bin/env bash
      cd "$HOME/nostrudel" && ${pnpm}/bin/pnpm dev
    '';
    executable = true;
  };

  home.file.".npmrc".text = ''
    fetch-timeout=300000
  '';
}

