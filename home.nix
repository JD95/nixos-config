{ inputs, pkgs, ... }:

let 
  home-dir = "/home/jeff";
in {
  home.username = "jeff";
  home.homeDirectory = home-dir;

  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "${home-dir}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "accounts/google/user" = {};
      "accounts/google/pass" = {};
    };
  };

  home.packages = with pkgs; [ 
    alacritty
    direnv
    git
    vscode    
    yazi
    kitty # required by hyprland
    rclone
  ];

  programs.kitty.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      monitor = [ ",preferred,auto,1" ];
      bind = [
        "SUPER+SHIFT,Q,exec,hyprlock"
        "SUPER,P,exec,hyprshot -m region"
        # bind to .
        "SUPER,code:60,exec,rofimoji"

        # Launch Applications
        "SUPER,Return,exec,alacritty"
        "SUPER,SPACE,exec,rofi -show drun"

        # Focused Window
        "SUPER,H,movefocus,l"
        "SUPER,J,movefocus,d"
        "SUPER,K,movefocus,u"
        "SUPER,L,movefocus,r"

        # Window Position 
        "SUPER+SHIFT,H,movewindow,l"
        "SUPER+SHIFT,J,movewindow,d"
        "SUPER+SHIFT,K,movewindow,u"
        "SUPER+SHIFT,L,movewindow,r"

        # Window Size
        "SUPER+ALT,H,resizeactive,-50 0"
        "SUPER+ALT,J,resizeactive,0 -50"
        "SUPER+ALT,K,resizeactive,0 50"
        "SUPER+ALT,L,resizeactive,50 0"

        # Window State
        "SUPER,Q,killactive"
        "SUPER,F,togglefloating,"

        # Workspace Focus
        "SUPER+CTRL,1,focusworkspaceoncurrentmonitor,1"
        "SUPER+CTRL,2,focusworkspaceoncurrentmonitor,2"
        "SUPER+CTRL,3,focusworkspaceoncurrentmonitor,3"
        "SUPER+CTRL,4,focusworkspaceoncurrentmonitor,4"
        "SUPER+CTRL,5,focusworkspaceoncurrentmonitor,5"
        "SUPER+CTRL,6,focusworkspaceoncurrentmonitor,6"
        "SUPER+CTRL,7,focusworkspaceoncurrentmonitor,7"
        "SUPER+CTRL,8,focusworkspaceoncurrentmonitor,8"
        "SUPER+CTRL,9,focusworkspaceoncurrentmonitor,9"
        "SUPER,TAB,focusworkspaceoncurrentmonitor,+1"
        "SUPER+SHIFT,TAB,focusworkspaceoncurrentmonitor,-1"

        # Workspace Windows 
        "SUPER+CTRL+SHIFT,1,movetoworkspacesilent,1"
        "SUPER+CTRL+SHIFT,2,movetoworkspacesilent,2"
        "SUPER+CTRL+SHIFT,3,movetoworkspacesilent,3"
        "SUPER+CTRL+SHIFT,4,movetoworkspacesilent,4"
        "SUPER+CTRL+SHIFT,5,movetoworkspacesilent,5"
        "SUPER+CTRL+SHIFT,6,movetoworkspacesilent,6"
        "SUPER+CTRL+SHIFT,7,movetoworkspacesilent,7"
        "SUPER+CTRL+SHIFT,8,movetoworkspacesilent,8"
        "SUPER+CTRL+SHIFT,9,movetoworkspacesilent,9"

        # Volume Controls
        "CTRL,F6,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        "CTRL,F7,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ];
      bindm = [
        "SUPER,mouse:272,movewindow"
        "SUPER,mouse:273,resizewindow"
      ];
      cursor = {
        # Prevents stutter when customizing 
        # the cursor
        no_hardware_cursors = true;
      };
      misc = {
        # Makes resizing windows a bit smoother
        animate_manual_resizes = true;
      };
      exec-once = [
        "mako"
        "nm-applet"
        "hyprpaper"
        "blueman-applet"
        "lxsession"
      ];
      input = {
        kb_layout = "us";
        kb_options = [
          "ctrl:nocaps"
        ];
        follow_mouse = 1;
      };
    };
  };


  programs.waybar.enable = true;
  programs.rofi.enable = true;
  programs.hyprlock.enable = true;
  services.mako.enable = true;
  services.hypridle.enable = true;
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "/home/jeff/Pictures/wallpapers/penrose_1.png"
        "/home/jeff/Pictures/wallpapers/penrose_2.png"
        "/home/jeff/Pictures/wallpapers/penrose_3.png"
        "/home/jeff/Pictures/wallpapers/penrose_4.png"
        "/home/jeff/Pictures/wallpapers/penrose_5.png"
        "/home/jeff/Pictures/wallpapers/penrose_6.png"
        "/home/jeff/Pictures/wallpapers/penrose_7.png"
        "/home/jeff/Pictures/wallpapers/penrose_8.png"
      ];
      wallpaper = [
        ",/home/jeff/Pictures/wallpapers/penrose_1.png"
      ];
    };
  };

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
    settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = "catppuccin-macchiato-mauve-compact";
        color-scheme = "prefer-dark";
      };
    };
  };

  qt = {
      enable = true;
      platformTheme.name = "gtk";
  };
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 12;
  };
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "macchiato";
        accent = "lavender";
      };
      name = "Papirus-Dark";
    };
    theme = {
        name = "catppuccin-macchiato-mauve-compact";
        package = pkgs.catppuccin-gtk.override {
          accents = ["mauve"];
          variant = "macchiato";
          size = "compact";
        };
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  systemd.user.services.sync-google-drive = {
    Unit = {
      Description = "Sync Google Drive";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "sync-google-drive" ''
        ${pkgs.coreutils}/bin/echo "Starting sync of google drive"
        ${pkgs.rclone}/bin/rclone bisync \
            --resync \
            "google:/" "${home-dir}/gdrive" \
            --compare size,modtime,checksum \
            --modify-window 1s \
            --create-empty-src-dirs \
            --drive-acknowledge-abuse \
            --drive-skip-gdocs \
            --drive-skip-shortcuts \
            --drive-skip-dangling-shortcuts \
            --metadata \
            --progress \
            --verbose \
            --log-file "${home-dir}/.config/rclone/rclone.log" 
        ''}";
    };
  };

  home.stateVersion = "25.05"; 
}
