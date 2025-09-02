{ config, pkgs, ... }:

{
  home.username = "jeff";
  home.homeDirectory = "/home/jeff";

  home.packages = with pkgs; [ 
    git
    vscode    
    alacritty
    yazi
  ];

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
        ];
      };
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          custom-hot-corners-extended.extensionUuid
          wallpaper-slideshow.extensionUuid
        ];
      };
    };
  };

  home.stateVersion = "25.05"; 
}
