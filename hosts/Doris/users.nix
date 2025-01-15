{
  pkgs,
  username,
  newUsers,
  ...
}: let
  inherit (import ./variables.nix) gitUsername;
  sharedGroup = "shared";
  sharedMode = "775";

  # Common user configuration
  makeUserConfig = description: {
    homeMode = "${sharedMode}";
    isNormalUser = true;
    description = description;
    password = "password";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "scanner"
      "lp"
      "scanner"
      "lpadmin"
      "docker"
      sharedGroup
    ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
    packages = with pkgs; [];
  };
in {
  users = {
    groups.${sharedGroup} = {};

    users = {
      "${username}" = makeUserConfig "${gitUsername}";
      "${newUsers.alice}" = makeUserConfig "Alice";
      "${newUsers.bob}" = makeUserConfig "Bob";
      "${newUsers.carol}" = makeUserConfig "Carol";
    };
  };
}
