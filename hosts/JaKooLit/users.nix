# users.nix
{
  pkgs,
  username,
  secondUser ? null,  # optional parameter for alice
  ...
}: let
  inherit (import ./variables.nix) gitUsername;
  sharedGroup = "shared";
  sharedMode = "775";
in {
  users = {
    groups.${sharedGroup} = {};

    users = {
      # bimmer configuration
      "${username}" = {
        homeMode = "${sharedMode}";
        isNormalUser = true;
        description = "${gitUsername}";
        extraGroups = [
          "networkmanager"
          "wheel"
          "libvirtd"
          "scanner"
          "lp"
          "video"
          "input"
          "audio"
          sharedGroup
        ];
        packages = with pkgs; [];
      };
    } // (if secondUser != null then {
      # alice configuration (only created if secondUser is specified)
      "${secondUser}" = {
        homeMode = "${sharedMode}";
        isNormalUser = true;
        password = "password";
        description = "${gitUsername}";
        extraGroups = [
          "networkmanager"
          "wheel"
          "libvirtd"
          "scanner"
          "lp"
          "video"
          "input"
          "audio"
          sharedGroup
        ];
        packages = with pkgs; [];
      };
    } else {});

    defaultUserShell = pkgs.zsh;
  };

  environment.shells = with pkgs; [zsh];
  environment.systemPackages = with pkgs; [fzf];

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      ohMyZsh = {
        enable = true;
        plugins = ["git"];
        theme = "xiong-chiamiov-plus";
      };

      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      promptInit = ''
        fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc
        source <(fzf --zsh);
        HISTFILE=~/.zsh_history;
        HISTSIZE=10000;
        SAVEHIST=10000;
        setopt appendhistory;
      '';
    };
  };
}

