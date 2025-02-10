{pkgs, ...}: {
  stylix = {
    enable = true;
    image = builtins.fetchurl {
      url = "file://${toString ./wallpapers/0253.jpg}";
      sha256 = "sha256:0skmjlkrgvz69vwciia6dgaz84x1v5cf2bivhmnhsiyir6gxx05v";
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
        terminal = 12;
        desktop = 11;
        popups = 12;
      };
    };
  };
}
