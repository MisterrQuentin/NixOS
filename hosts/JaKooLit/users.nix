{
  pkgs,
  username,
  ...
}: let
  inherit (import ./variables.nix) gitUsername;
  currentUser = "bimmer"; # Your original username
in {
  users = {
    # Keep your original user
    users."${currentUser}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      # Keep your existing password
    };

    # Add the new user
    users."${username}" = {
      homeMode = "755";
      password = "password";
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
      ];

      packages = with pkgs; [
      ];
    };

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
