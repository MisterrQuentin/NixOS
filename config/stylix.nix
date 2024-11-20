{ pkgs, ... }:
{
  stylix = {
    enable = true;
    image = builtins.fetchurl {
      url = "file://${toString ./wallpapers/wallhaven1.jpg}";
      sha256 = "sha256:1113k9vzapkxqbf42xagj86mi5mbrr0li5mvb9b3mkj3micj09rj";
    };
    polarity = "dark";
    opacity.terminal = 0.8;
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
    cursor.size = 48;
    fonts = {
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };
}

