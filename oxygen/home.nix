{ pkgs, config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.machines/oxygen/dotfiles";
  makeLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  # does not work on wayland until NixOS 22.11 (see below in bashrcExtra)
  # https://github.com/NixOS/nixpkgs/pull/185987
  # https://github.com/nix-community/home-manager/issues/1011
  home.sessionPath = [
    "${config.xdg.dataHome}/pnpm"
    "${config.home.homeDirectory}/.cargo/bin"
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
    PNPM_HOME = "${config.xdg.dataHome}/pnpm";
  };

  home.file = {
    ".bash_aliases".source = makeLink "aliases.bash";
    ".dotfiles".source = makeLink ".";
    ".inputrc".source = makeLink "inputrc";
    ".ideavimrc".source = makeLink "ideavimrc";
  };
  xdg.configFile = {
    "alacritty/alacritty.yml".source = makeLink "alacritty.yaml";
    "Code/User/settings.json".source = makeLink "vscode.json";
    "helix/config.toml".source = makeLink "helix.toml";
    "nvim/lua/settings.lua".source = makeLink "neovim.lua";
    "nushell/extra-config.nu".source = makeLink "config.nu";
    "zed/settings.json".source = makeLink "zed-settings.json";
    "zed/keymap.json".source = makeLink "zed-keymap.json";
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Inter Display" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };

  dconf.settings = {
    "org/gnome/desktop/input-sources".xkb-options = [ "lv3:lalt_switch" ];
    "org/gnome/desktop/interface".clock-show-weekday = true;
    "org/gnome/desktop/interface".enable-hot-corners = false;
    "org/gnome/desktop/interface".font-name = "Inter Display 12";
    "org/gnome/desktop/interface".document-font-name = "Inter Display 12";
    "org/gnome/desktop/interface".monospace-font-name = "JetBrainsMono Nerd Font";
    "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";
    "org/gnome/desktop/peripherals/touchpad".tap-to-click = true;
    "org/gnome/desktop/wm/preferences".audible-bell = false;
    "org/gnome/desktop/wm/preferences".resize-with-right-button = true;
    "org/gnome/mutter".overlay-key = "";
    # https://bugs.chromium.org/p/chromium/issues/detail?id=1356014#c54
    # "org/gnome/mutter".experimental-features = [ "scale-monitor-framebuffer" ];
    "org/gnome/shell/keybindings".toggle-overview = [ "<Super>space" ];
  };

  programs = {
    nushell = {
      enable = true;
      package = pkgs.unstable.nushell;
      configFile.text = ''
        source ${config.xdg.configHome}/nushell/extra-config.nu
      '';
    };
    bash = {
      enable = true;
      bashrcExtra = ''
        stty -ixon # disable terminal scroll lock (Ctrl+S/Ctrl+q)
        shopt -s autocd # auto change directories
        source ~/.bash_aliases

        # workaround for home.sessionVariables (remove when updating to NixOS 22.11)
        # https://github.com/NixOS/nixpkgs/pull/185987
        # https://github.com/nix-community/home-manager/issues/1011
        export PNPM_HOME=${config.xdg.dataHome}/pnpm
        export PATH="${config.xdg.dataHome}/pnpm:${config.home.homeDirectory}/.cargo/bin:$PATH"
      '';
    };
    bat = {
      enable = true;
      config.theme = "GitHub";
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza = {
      enable = true;
    };
    fzf = {
      enable = true;
      enableBashIntegration = true;
    };
    git = {
      enable = true;
      userName = "Felix Andreas";
      userEmail = "felix.andreas95@googlemail.com";
      includes = [
        {
          condition = "hasconfig:remote.*.url:git@github.com\:leptonic-solutions/**";
          contents.user.email = "felix.andreas@leptonic.solutions";
        }
      ];
      # ignores = [ ".vscode" ];
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
      aliases = {
        s = "status -uall";
        a = "add";
        aa = "add --all";
        c = "commit --verbose";
        cm = "c --message";
        ca = "c --amend";
        can = "ca --no-edit";
        cp = "!git c && git push";
        cmp = "!git cm \"$1\" && git push && :";
        aac = "!git aa && git c";
        aacm = "!git aa && git cm";
        aacp = "!git aa && git cp";
        aacmp = "!git aa && git cmp";
        prp = "!git pull --rebase && git push";
        size = "!git ls-tree -r --long HEAD | awk '{sum+=$4} END {print sum}' | numfmt --to=iec";
        new = "!git switch main && git pull && git switch -c";
      };
      attributes = [ "*.lockb binary diff=lockb" ];
      delta = {
        enable = true;
        options.syntax-theme = "GitHub";
      };
    };
    home-manager.enable = true;
    neovim = {
      enable = true;
      extraConfig = ''
        luafile ${config.xdg.configHome}/nvim/lua/settings.lua
      '';
      extraPackages = with pkgs; [
        (python3.withPackages (
          ps: with ps; [
            black
            isort
            pylint
          ]
        ))
        pyright
      ];
      plugins = with pkgs.vimPlugins; [
        # github theme
        (pkgs.vimUtils.buildVimPlugin {
          name = "github-nvim-theme";
          src = pkgs.fetchFromGitHub {
            owner = "projekt0n";
            repo = "github-nvim-theme";
            rev = "v1.1.2";
            sha256 = "sha256-ur/65NtB8fY0acTUN/Xw9fT813UiL3YcP4+IwkaUzTE=";
          };
          nativeBuildInputs = with pkgs; [ luajitPackages.luacheck ];
        })
        # ide features
        bufferline-nvim
        nvim-cmp
        nvim-tree-lua
        nvim-web-devicons
        telescope-nvim
        # editing
        comment-nvim
        # language support
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        nvim-treesitter-textobjects
      ];
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
    };
    nix-index.enable = true;
    starship = {
      enable = true;
      package = pkgs.unstable.starship;
      enableNushellIntegration = true;
      settings = {
        add_newline = false;
        username.show_always = true;
        username.format = "[$user](bold red) ";
        hostname.ssh_only = false;
        hostname.format = "at [$hostname](bold blue) ";
        directory.format = "in [$path]($style)[$read_only]($read_only_style) ";
        git_branch.format = "on [$branch](bold green) ";
        character.format = " "; # somehow empty string leads to no linebreak??
        continuation_prompt = " ";
        container.disabled = true;
      };
    };
    tealdeer = {
      enable = true;
      settings = {
        display.use_pager = true;
        updates.auto_update = true;
      };
    };
    vscode = {
      enable = true;
      package = pkgs.unstable.vscode;
      extensions = with pkgs.unstable.vscode-extensions; [
        # github.github-vscode-theme
        # ms-vsliveshare.vsliveshare
        # vadimcn.vscode-lldb
        # matklad.rust-analyzer
        # ms-vscode.cpptools
      ];
    };
    zellij = {
      enable = true;
      settings = {
        copy_command = "wl-copy";
        theme = "default";
        themes.default = {
          fg = 7;
          bg = 23; # this is just for text selection
          black = 0;
          red = 1;
          green = 2;
          yellow = 3;
          blue = 4;
          magenta = 5;
          cyan = 6;
          white = 7;
          orange = 208;
          gray = 247;
        };
      };
    };
    zoxide.enable = true;
  };

  home.packages = with pkgs; [
    # fonts
    inter
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    # desktop
    unstable.alacritty
    unstable.anytype
    beekeeper-studio
    bitwarden
    easyeffects
    firefox
    ghostty
    gimp
    (google-chrome.override {
      # see https://bugs.chromium.org/p/chromium/issues/detail?id=1356014#c54
      commandLineArgs = "--disable-features=WaylandFractionalScaleV1";
    })
    unstable.helix
    spotify
    qemu
    vlc
    wl-clipboard # access clipboard from console on Wayland
    xclip # access clipboard from console on X
    unstable.zed-editor.fhs
    # cli tools
    brotli
    cloudflared
    ffmpeg
    just
    pandoc
    scrcpy
    zellij
    # git
    git
    git-lfs
    gh
    # containers
    buildah
    cntr
    unstable.distrobox
    dive
    podman-compose
    skopeo
    # kubernetes
    k9s
    kube3d
    kubectl
    # nix
    nix-index
    nixpkgs-fmt
    nixfmt-rfc-style
    patchelf
    unstable.nickel
    unstable.nil
    unstable.nixd
    unstable.devenv
    # c
    gcc
    gdb
    # rust
    # rustup
    # python
    (python312.withPackages (
      ps: with ps; [
        httpx
        ipykernel
        ipython
        matplotlib
        numpy
        pandas
        scipy
        # tooling
        # black # use ruff instead
        isort
        mypy
        pip
        pylint
        pytest
        rope
      ]
    ))
    unstable.pyright
    unstable.ruff
    unstable.uv
    # elm
    elmPackages.elm
    elmPackages.elm-test
    elmPackages.elm-format
    #haskell
    ghc
    haskell-language-server
    # go
    go
    # js
    nodejs
    nodePackages.pnpm
    bun
    deno
    nodePackages.yaml-language-server
    # R
    (rWrapper.override {
      packages = with pkgs.rPackages; [
        devtools
        data_table
        dplyr
        purrr
      ];
    })
    # wasm
    wabt
    wasmer
    # zig
    unstable.zig
    unstable.zls
    # utils
    sysstat
    linuxPackages.cpupower
    # classic unix commands
    curl
    dstat
    file
    htop
    lsof
    neofetch
    nmap
    socat
    # modern unix commands
    bat
    delta
    dogdns
    duf
    dust
    eza
    fd
    fzf
    hyperfine
    hexyl
    jless
    jq
    kondo
    pastel
    procs
    ripgrep
    tealdeer
    websocat
    xcolor
    xh
    yj
    zoxide
  ];
}
