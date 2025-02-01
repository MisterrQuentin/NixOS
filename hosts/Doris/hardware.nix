# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
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

  environment.systemPackages = with pkgs; [
    dmraid
    mdadm
    multipath-tools
    nvme-cli # Add this
    kmod
    ntfs3g # Add this for NTFS support
  ];

  boot.initrd.availableKernelModules = [
    "vmd"
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "uas"
    "sd_mod"
    "rtsx_pci_sdmmc"
    "dm-raid"
    "raid0"
    "raid1"
    "md_mod" # Add RAID modules
  ];

  boot.swraid = {
    enable = true;
    mdadmConf = ''
      MAILADDR root  # Add this line to specify an email address (e.g., root)
      ARRAY /dev/md/imsm0 metadata=imsm UUID=5729fdba:dedc7475:1183b1d9:ae4e5b13
      ARRAY /dev/md/ARRAY0_0 container=imsm0 member=0
    '';
  };
  boot.initrd.services.udev.packages = [pkgs.dmraid];
  boot.initrd.kernelModules = [
    "vmd"
    "dm-raid"
    "raid0"
    "dm-snapshot"
    "ahci"
    "sd_mod"
  ];
  boot.kernelModules = ["kvm-intel" "dm_raid" "raid0" "raid1" "raid10" "raid456" "dm_mod" "vmd"];
  boot.supportedFilesystems = ["raid"];
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "vmd=1"
    "nvme.use_threaded_interrupts=1"
    # Remove the rd.md.uuid line
  ];
  boot.extraModulePackages = [];

  #LUKS encryption
  boot.initrd.luks.devices = {
    cryptedd = {
      device = "/dev/disk/by-uuid/f2d43813-71c8-412b-8f38-c25f48bbe4dd";
      preLVM = true;
      allowDiscards = true;
    };
  };
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ad5591f0-7a6a-4fe1-a983-a543240b76c9";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/91B9-CCF3";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };
  # Mount Windows NTFS partition (adjust UUID)
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/D2B0B6C1B0B6AAFD"; # From lsblk's md126p3
    fsType = "ntfs";
    options = ["ro" "nofail" "uid=1000" "gid=100"]; # Read-only for safety
  };
  swapDevices = [
    {device = "/dev/disk/by-uuid/e35a4ecf-7581-4e8b-967b-6a130e30b620";}
  ];
  fileSystems."/mnt/windows-recovery" = {
    device = "/dev/disk/by-uuid/581AA6411AA61C4E"; # md126p5
    fsType = "ntfs";
    options = ["ro" "nofail"];
  };

  fileSystems."/mnt/dell-support" = {
    device = "/dev/disk/by-uuid/4A5C5ACE5C5AB503"; # md126p7
    fsType = "ntfs";
    options = ["ro" "nofail"];
  };
  # fileSystems."/mnt/new-volume" = {
  #   device = "/dev/disk/by-uuid/14CC3926CC390390";
  #   fsType = "ntfs";
  #   options = ["rw" "nofail"]; # Use "rw" for write access
  # };
  systemd.services.dmraid = {
    description = "Activate DM RAID arrays";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.dmraid}/bin/dmraid -ay";
      RemainAfterExit = true;
    };
  };
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp56s0u1c2.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
