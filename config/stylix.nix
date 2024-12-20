{pkgs, ...}: {
  stylix = {
    enable = true;
    image = builtins.fetchurl {
      url = "file://${toString ./wallpapers/0298.jpg}";
      sha256 = "sha256:1aq02549bqbj9jw1wsvp8yhsasbap996klghn13k3dvnwhm207z2";
    };
    polarity = "dark";
    opacity.terminal = 0.8;
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
    cursor.size = 48;
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono; # Changed this line
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
        terminal = 18;
        desktop = 11;
        popups = 12;
      };
    };
  };
}
