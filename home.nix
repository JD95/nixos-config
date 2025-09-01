{ config, pkgs, ... }:

{
  home.username = "jeff";
  home.homeDirectory = "/home/jeff";

  home.packages = with pkgs; [ 
    git
    vim
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

  programs.vivaldi = {
    enable = true;
  };

  home.stateVersion = "25.05"; 
}
