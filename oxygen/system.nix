{ pkgs, kernel-fix, ... }:

{
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
    };
  };
  nixpkgs.config.allowUnfree = true;

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.useTmpfs = true;
    supportedFilesystems = [ "ntfs" ];
    kernelPackages = kernel-fix.linuxPackages;
    # kernelPackages = pkgs.unstable.linuxPackages_6_4;
    # Show proper password prompt
    plymouth.enable = true;
    initrd.systemd.enable = true; # (seems to be experimental)
  };

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

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
      extraGroups = [ "adbusers" "docker" "networkmanager" "wheel" ];
      password = "asdf";
      # shell = pkgs.unstable.nushell;
    };
  };

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;

    xkb = {
      layout = "custom";
      extraLayouts.custom = {
        symbolsFile = ./keyboard-layout;
        description = "Custom Keyboard Layout";
        languages = [ "eng" ];
      };
    };
  };

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services = {
    printing.enable = true;
    avahi.enable = true;
    avahi.nssmdns4 = true;
  };

  services.flatpak.enable = true;
  services.fwupd.enable = true;

  # # from https://nixos.wiki/wiki/OSX-KVM
  # virtualisation.libvirtd.enable = true;

  # boot.extraModprobeConfig = ''
  #   options kvm_intel nested=1
  #   options kvm_intel emulate_invalid_guest_state=0
  #   options kvm ignore_msrs=1
  # '';

  virtualisation = {
    docker = {
      enable = true;
      # deutsche bahn wifi fix
      # see https://unix.stackexchange.com/questions/539257/wlan-wifionice-deutsche-bahn-not-working-with-docker-installed
      daemon.settings = {
        default-address-pools = [
          { base = "172.19.0.0/16"; size = 24; }
        ];
      };
    };
    podman.enable = true;
    waydroid. enable = true;
    lxd.enable = true;
  };

  programs.adb.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      curl
      git
      htop
      neovim
      gnome.dconf-editor
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
