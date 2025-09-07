{ config, pkgs, ... }:

{
  system.stateVersion = "25.05";

  # Nix Settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./usb-wakeup-disable.nix
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
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  hardware.nvidia = {
    # Use the open source drivers
    # Recommended for RTX 20-Series
    open = true; 
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  # For Login screen
  services.displayManager.sddm.enable = true;
  programs.hyprland.enable = true;
  # For running commands as sudo
  security.polkit.enable = true;

  # Enable for external drive discovery
  # and auto mounting
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.devmon.enable = true;

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

  hardware.usb.wakeupDisabled = [
    # Keyboard
    { vendor = "04b4"; product = "0818"; }
    # Mouse
    { vendor = "25a7"; product = "fa07"; }
  ];

  # System Packages
  environment.systemPackages = with pkgs; [
    usbutils
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
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

  # User Packages
  users.users.jeff = {
    isNormalUser = true;
    description = "Jeff";
    extraGroups = [ 
      "networkmanager" "wheel" 
      # For Android Studio
      "kvm" "adbusers" 
      # For Nvidia
      "video"
      # For autoloading external drives
      "storage"
    ];
    packages = with pkgs; [
      vivaldi # web browser
      obsidian # notes
      vlc # media player
      quodlibet # music player and library manager
      discord # social app
      keepassxc # password manager
      cryptomator # encrypted vault manager
      jackett # torrent tracker
      android-studio
      ueberzugpp # image rendering in terminal via X11
      gnucash # accounting
      libreoffice-qt # office stuff 
      whatsie # whatsapp client
      musescore # music notation
      nautilus # file manager separate from gnome
      lxsession # gui sudoo entry
      hyprshot # screenshots
      age # secrets generation
    ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.dejavu-sans-mono
  ];

  # For Android Studio
  programs.adb.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jeff";
  };

  services.jackett.enable = true;
}
