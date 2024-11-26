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
      sharedGroup
    ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };
in {
  users = {
    groups.${sharedGroup} = {};

    users = {
      "${username}" = makeUserConfig "${gitUsername}";
      "${newUsers.user1}" = makeUserConfig "User1";
      "${newUsers.user2}" = makeUserConfig "User2";
      "${newUsers.user3}" = makeUserConfig "User3";
    };
  };
}
