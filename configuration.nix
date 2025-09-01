{ config, pkgs, ... }:

{
  system.stateVersion = "25.05";

  # Nix Settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sdb";
  boot.loader.grub.useOSProber = true;

  # Networking
  networking.hostName = "nixos";
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

  # System Packages
  environment.systemPackages = with pkgs; [
    usbutils
    gnome-tweaks
    gnomeExtensions.custom-hot-corners-extended
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  # Remove Gnome Bloat Apps
  services.gnome.games.enable = false;
  environment.gnome.excludePackages = with pkgs; [
    epiphany # web browser
    gedit # text editor
    simple-scan # document scanner
    totem # video player
    yelp # help tool
    geary # email client
    seahorse # password manager
    gnome-music # music player
    gnome-tour # gnome guide 
  ];

  # These help fix an issue with an external
  # drive getting lost after suspends 
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

  # Necessary to prevent hangs during suspend 
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  # User Packages
  users.users.jeff = {
    isNormalUser = true;
    description = "Jeff";
    extraGroups = [ 
      "networkmanager" "wheel" 
      # For Android Studio
      "kvm" "adbusers" 
    ];
    packages = with pkgs; [
      vivaldi # web browser
      obsidian # notes
      vlc # media player
      quodlibet # music player and library manager
      discord # social app
      keepassxc # password manager
      cryptomator # encrypted vault manager
      jackett 
      android-studio
    ];
  };

  # For Android Studio
  programs.adb.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jeff";
  };

}
