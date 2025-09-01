# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sdb";
  boot.loader.grub.useOSProber = true;

  # Possible fixes for usb port not working after suspend
  boot.kernelParams = [ "usbcore.autosuspend=-1" "xhci_hcd.quirks=270336" ];
  systemd.services.usb-restart = {
    enable = true;
    description = "Restart USBs after suspension";
    after = [ "suspend.target" ];
    wantedBy = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.coreutils}/bin/echo \"Disabling usb port 6\""
        "${pkgs.kmod}/bin/modprobe -r xhci_pci"
        "${pkgs.coreutils}/bin/echo \"Enabling usb port 6\""
	"${pkgs.kmod}/bin/modprobe xhci_pci"
      ];
    };
  };

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Graphics and Desktop 
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.jackett.enable = true;

  # For Android Studio
  programs.adb.enable = true;

  users.users.jeff = {
    isNormalUser = true;
    description = "Jeff";
    extraGroups = [ 
      "networkmanager" "wheel" 
      # For Android Studio
      "kvm" "adbusers" 
    ];
    packages = with pkgs; [
      vivaldi
      obsidian
      vlc
      quodlibet
      discord
      keepassxc
      cryptomator
      jackett
      android-studio
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    usbutils
    gnome-tweaks
    gnomeExtensions.custom-hot-corners-extended
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
