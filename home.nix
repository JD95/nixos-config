{ config, pkgs, ... }:

{
  home.username = "jeff";
  home.homeDirectory = "/home/jeff";

  home.packages = with pkgs; [ 
    alacritty
    direnv
    git
    vscode    
    yazi
    kitty # required by hyprland
  ];

  programs.kitty.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      monitor = [ ",preferred,auto,1" ];
      bind = [
        "SUPER,Return,exec,alacritty"
        "SUPER,D,exec,rofi -show drun"
        "SUPER,Q,killactive"
      ];
      bindm = [
        "SUPER,mouse:272,movewindow"
        "SUPER,mouse:273,resizewindow"
      ];
      exec-once = [
        "waybar"
        "mako"
        "nm-applet"
        "blueman-applet"
      ];
      input = {
        kb_layout = "us";
        kb_options = [
          "caps:ctrl"
        ];
        follow_mouse = 1;
      };
    };
  };


  programs.waybar.enable = true;
  programs.rofi.enable = true;
  services.mako.enable = true;
  services.hypridle.enable = true;

  programs.yazi = {
    enable = true;
  };
  
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  programs.bash = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font.normal = { 
        family = "Dejavu Sans Mono";
        style = "Regular";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "JD95";
    userEmail = "jeffreydwyer95@outlook.com";
  };
   
  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          vscodevim.vim
          jnoortheen.nix-ide
          haskell.haskell
          mkhl.direnv
          rust-lang.rust-analyzer
        ];
      };
    };
  };

  dconf = {
    enable = true;
    # settings = {
    #   "org/gnome/shell" = {
    #     disable-user-extensions = false;
    #     enabled-extensions = with pkgs.gnomeExtensions; [
    #       custom-hot-corners-extended.extensionUuid
    #       wallpaper-slideshow.extensionUuid
    #     ];
    #   };
    # };
  };

  home.stateVersion = "25.05"; 
}
