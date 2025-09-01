{ config, pkgs, ... }:

{
  home.username = "jeff";
  home.homeDirectory = "/home/jeff";

  home.packages = with pkgs; [ 
    git
    vscode    
  ];
  
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  programs.bash = {
    enable = true;
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

  home.stateVersion = "25.05"; 
}