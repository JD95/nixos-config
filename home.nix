{ inputs, pkgs, ... }:

let
  home-dir = "/home/jeff";
  external-drive-dir = "/run/media/jeff/easystore";
in {
  home.username = "jeff";
  home.homeDirectory = home-dir;

  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${home-dir}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "accounts/google/user" = { };
      "accounts/google/pass" = { };
    };
  };

  home.packages = with pkgs; [
    alacritty
    direnv
    glance # dashboards
    kitty # required by hyprland
    rclone
    vscode
    wlsunset
    yazi
    zoxide
  ];

  programs.kitty.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;

    plugins = with pkgs.hyprlandPlugins; [
      hyprexpo
    ];

    settings = {
      general = {
        # Remove space around windows
        gaps_out = 0;
        gaps_in = 0;
      };
      monitor = [ ",preferred,auto,1" ];
      windowrule = [
        "noinitialfocus,floating:1,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
        "float,floating:1,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
      ];
      decoration = {
        # https://wiki.hypr.land/Configuring/Variables/#blur
        blur = {
          enabled = true;
          size = 6;
          new_optimizations = true;
          xray = true;
          popups = true;
        };
      };
      bind = [
        "SUPER+CRTL,Q,exec,hyprlock"
        ''SUPER,P,exec,grim -g "$(slurp)" - | swappy -f -''
        # bind to .
        "SUPER,code:60,exec,wofi-emoji"

        # Launch Applications
        "SUPER,Return,exec,alacritty"
        "SUPER,SPACE,exec,wofi --show drun"

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
        "SUPER,TAB,hyprexpo:expo,toggle"
        "SUPER,mouse_up,focusworkspaceoncurrentmonitor,m+1"
        "SUPER,mouse_down,focusworkspaceoncurrentmonitor,m-1"

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
        "SUPER,M,movetoworkspacesilent,emptym+1"

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
      plugin = {
        hyprexpo = {
          columns = 3;
          gap_size = 5;
          bg_col = "rgb(111111)";
        };
      };
      misc = {
        # Makes resizing windows a bit smoother
        animate_manual_resizes = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };
      exec-once = [
        "waybar"
        "mako"
        "nm-applet"
        "hyprpaper"
        "blueman-applet"
        # For password prompts
        "lxsession"
      ];
      input = {
        kb_layout = "us";
        kb_options = [ "ctrl:nocaps" ];
        follow_mouse = 1;
        natural_scroll = true;
      };
    };
  };

  programs.waybar = {
    enable = true;
    style = builtins.readFile ./waybar/style.css;
    settings = [{
      layer = "top";
      position = "top";
      mod = "dock";
      exclusive = true;
      passthrough = false;
      gtk-layer-shell = true;
      height = 0;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ ];
      modules-right = [ "pulseaudio" "custom/divider" "clock" "custom/space" ];
      pulseaudio = {
        format = "{icon} {volume}%";
        tooltip = false;
        format-muted = "Muted";
      };
      "custom/divider" = {
        format = " | ";
        interval = "once";
        tooltip = false;
      };
      "custom/space" = {
        format = " ";
        interval = "once";
        tooltip = false;
      };
    }];
  };

  programs.wofi.enable = true;
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
      };
      background = [
        {
          color = "rgba(0,0,0,1.0)";
          blur_passes = 0;
        }
      ];
      input-field = [
        {
          size = "200, 50";
          position = "0m -80";
          monitor = "DP-4";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)"; 
          inner_color = "rgb(91, 96, 120)"; 
          outer_color = "rgb(24, 25, 38)"; 
          outline_thickness = 5;
        }
      ];
    };
  };
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
      wallpaper = [ ",/home/jeff/Pictures/wallpapers/penrose_1.png" ];
    };
  };

  services.wlsunset = {
    enable = true;
    latitude = 34.03;
    longitude = -118.35;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.yazi = {
    enable = true;
    plugins = {
      rsync = pkgs.yaziPlugins.rsync;
      mount = pkgs.yaziPlugins.mount;
    };
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  programs.bash = { enable = true; };

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
    extraConfig = {
      diff.tool = "vimdiff";
    };
  };

  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        userSettings = {
          "nix.suggest.paths" = false;
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
          "nix.serverSettings" = {
            nil = { formatting = { command = [ "nixfmt" ]; }; };
          };
        };
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
        accents = [ "mauve" ];
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
        gtk-overlay-scrolling=true
      '';
    };
  };

  systemd.user.services.sync-google-drive = {
    Unit = { Description = "Sync Google Drive"; };
    Install = { WantedBy = [ "default.target" ]; };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "sync-google-drive" ''
        ${pkgs.coreutils}/bin/echo "Starting sync of google drive"
        ${pkgs.rclone}/bin/rclone bisync \
            --resync \
            "google:/" "${external-drive-dir}/google-drive" \
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

  systemd.user.services.cycle-wallpaper = {
    Unit = { Description = "Cycles Wallpapers managed by Hyprpaper"; };

    Install = {

      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = let
        script = pkgs.writeShellApplication {
          name = "cycle-wallpaper";

          runtimeInputs = with pkgs; [ hyprland coreutils ];

          text = ''
            WALLPAPER_DIR="$HOME/Pictures/wallpapers"
            CURRENT_WALL=$(hyprctl hyprpaper listloaded | grep wallpaper | sed 's/wallpaper=,,//')

            # If no wallpaper is currently loaded, select any image
            if [ -z "$CURRENT_WALL" ]; then
              WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" \) | shuf -n 1)
            else
              # Otherwise, pick a random wallpaper that is not the current one
              WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" \) ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)
            fi

            # Apply the new wallpaper
            if [ -n "$WALLPAPER" ]; then
              hyprctl hyprpaper reload ,"$WALLPAPER"
            fi 
          '';
        };
      in "${script}/bin/cycle-wallpaper";
    };
  };

  services.glance = {
    enable = true;
    settings = {
      server = { port = 8081; };
      pages = [{
        name = "Home";
        columns = [{
          size = "full";
          widgets = [
            {
              type = "rss";
              title = "News";
              feeds = [{ url = "https://www.reddit.com/r/news.rss"; }];
            }
            {
              type = "rss";
              title = "Politics";
              feeds = [
                # Adam Mockler
                { url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC8DA4o0SyaGfyVaBLbF5EXg"; }
                # Hasan
                { url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCtoaZpBnrd0lhycxYJ4MNOQ"; }
                # Vaush
                { url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC1E-JS8L0j1Ei70D9VEFrPQ"; }
                # The Rational National
                { url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCo9oQdIk1MfcnzypG3UnURA"; }
              ];
            }
          ];
        }];
      }];
    };
  };

  home.stateVersion = "25.05";
}
