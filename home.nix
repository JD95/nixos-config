{ inputs, pkgs, ... }:

let
  home-dir = "/home/jeff";
  external-drive-dir = "/run/media/jeff/easystore";
in {
  home.username = "jeff";
  home.homeDirectory = home-dir;

  imports = [ 
    (import ./home/sops.nix { inherit home-dir; })
    (import ./home/hyprland.nix)
    inputs.sops-nix.homeManagerModules.sops 
    inputs.nvf.homeManagerModules.default
  ];

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

  services.udiskie = {
    enable = true;
    automount = true;
  };

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };
        viAlias = true;
        vimAlias = true;
        lsp.enable = true; 
        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;

        languages = {
          enableLSP = true;
          enableTreesitter = true;
          nix.enable = true;
          rust.enable = true;
        };
      };
    };
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
