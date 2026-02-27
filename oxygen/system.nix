{ pkgs, kernel-fix, ... }:

{
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 90d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 16;
      efi.canTouchEfiVariables = true;
    };
    tmp.useTmpfs = true;
    supportedFilesystems = [ "ntfs" ];
    kernelPackages = kernel-fix.linuxPackages;
    # Show proper password prompt
    plymouth.enable = true;
    initrd.systemd.enable = true; # (seems to be experimental)
  };

  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";

  # todo: force hibernation to ensure encryption
  # systemd.sleep.extraConfig = ''
  #   HibernateDelaySec=5
  # '';

  networking.firewall.enable = false;

  time.timeZone = "Europe/Berlin";

  users = {
    mutableUsers = false;
    users.felix = {
      isNormalUser = true;
      extraGroups = [
        "adbusers"
        "docker"
        "networkmanager"
        "wheel"
      ];
      password = "asdf";
    };
  };

  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    flatpak.enable = true;
    kanata = {
      enable = true;
      keyboards.default.configFile = ./kanata.kbd;
    };
    # printer stuff. not sure what is actually needed
    avahi.enable = true;
    avahi.nssmdns4 = true;
    printing.enable = true;
  };

  virtualisation = {
    podman.enable = true;
    docker = {
      enable = true;
      # deutsche bahn wifi fix
      # see https://unix.stackexchange.com/questions/539257/wlan-wifionice-deutsche-bahn-not-working-with-docker-installed
      daemon.settings = {
        default-address-pools = [
          {
            base = "172.19.0.0/16";
            size = 24;
          }
        ];
      };
    };
  };

  programs = {
    nix-ld = {
      enable = true;
      libraries =
        with pkgs;
        [
          stdenv.cc.cc
          zlib
        ]
        ++ (pkgs.steam-run.args.multiPkgs pkgs);
    };
  };

  environment = {
    systemPackages = with pkgs; [
      curl
      git
      htop
      neovim
      dconf-editor
      iptables
    ];
    variables.EDITOR = "nvim";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
