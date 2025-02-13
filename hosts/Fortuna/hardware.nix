{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usbhid" "uas" "sd_mod" "rtsx_pci_sdmmc"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a5db0085-d207-4d5d-87e4-96887dc650fe";
    fsType = "ext4";
  };

  boot.initrd.luks.devices = {
    "luks-80075794-f11d-4754-96f9-c230b9e69991" = {
      device = "/dev/disk/by-uuid/80075794-f11d-4754-96f9-c230b9e69991";
      keyFile = null;
    };
    "luks-597b1636-91bd-4fee-b789-12652099bd0b" = {
      device = "/dev/disk/by-uuid/597b1636-91bd-4fee-b789-12652099bd0b";
      keyFile = null;
    };
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A662-3D4C";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/24d77b7a-6dcd-49d3-acb1-10749d54e5e1";}
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
