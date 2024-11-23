{
  pkgs,
  username,
  newuser,
  ...
}:

let
  inherit (import ./variables.nix) gitUsername;
in
{
  users.users = {
    "${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "${gitUsername}";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "scanner"
        "lp"
        "scanner"
        "lpadmin"
      ];
      shell = pkgs.zsh;
      #shell = pkgs.bash;
      ignoreShellProgramCheck = true;
      packages = with pkgs; [
      ];
    };
    "${newuser}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "${gitUsername}";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "scanner"
        "lp"
        "scanner"
        "lpadmin"
      ];
      shell = pkgs.zsh;
      #shell = pkgs.bash;
      ignoreShellProgramCheck = true;
      initialPassword = "password";  # Add this for the new user
      packages = with pkgs; [
      ];
    };
  };
}
