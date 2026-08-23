# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "intel_pstate=active" ];
  boot.kernelModules = [ "ntsync" ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Nvidia Drivers
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."izzy" = {
    isNormalUser = true;
    description = "izzy";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # NTSYNC udev rules
  services.udev.extraRules = ''
    KERNEL=="ntsync", MODE="0666"
  '';

  # Environment Variables
  environment.sessionVariables = {
    FREETYPE_PROPERTIES="cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  curl
  git
  vim
  wl-clipboard
  pavucontrol
  adwaita-icon-theme
  wlogout
  starship
  fastfetch
  protonup-qt
  nwg-look
  btop-cuda
  grim
  slurp
  waybar
  swaynotificationcenter
  hyprpaper
  hypridle
  hyprlock
  fuzzel
  kitty
  zip
  unzip
  p7zip
  brave-origin
  xdg-utils
  xdg-user-dirs
  mpv
  yt-dlp
  ];
 
  # Hyprland
  programs.hyprland.enable = true;

  # Steam
  programs.steam.enable = true;

  # Fish Shell
  programs.fish.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  # Audio Stuff
  security.rtkit.enable = true;

  # Blueteeth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
 
  services.blueman.enable = true;

  # Fonts
  fonts.fontconfig = {
    enable = true;
    antialias = true;
    
   hinting = {
     enable = true;
     style = "slight";
   };
   subpixel = {
     rgba = "rgb";
     lcdfilter = "default";
   };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.ubuntu-mono
      ubuntu-classic
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
