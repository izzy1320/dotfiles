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
  boot.kernelParams = [ "amd_pstate=active" ];
  boot.kernelModules = [ "amd_3d_vcache" "ntsync" ];

  # Zram Swap
  zramSwap.enable = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Patch for NTSYNC
  boot.kernelPatches = [ {
    name = "ntsync-config";
    patch = null;
   structuredExtraConfig = with pkgs.lib.kernel; {
      NTSYNC = yes;
    };
   }
   ];
   
  # NTSYNC udev rules
  services.udev.extraRules = ''
    KERNEL=="ntsync", MODE="0666"
  '';
 
  # sched_ext stuff
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };  
 
  # Blueteeth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
  
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
    extraGroups = [ "networkmanager" "wheel" "gamemode" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Greetd with tuigreet
  services.greetd = {
    enable = true;
    
    # Configuration
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --cmd 'sway --unsupported-gpu'";
        user = "greeter";
      };
    };
  }; 
 
  # Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraOptions = [ "--unsupported-gpu" ];
    extraPackages = with pkgs; [
      swayidle
      swaylock
      swaybg
      swaynotificationcenter
      swayosd
     ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    wl-clipboard
    autotiling-rs
    pavucontrol
    adwaita-icon-theme
    wlogout
    fastfetch
    starship
    protonup-qt
    nwg-look
    btop
    grim
    slurp
    discord
    waybar
    fuzzel
    kitty
    git
    zip
    unzip
    p7zip
    easyeffects
    rnnoise-plugin
    deepfilternet
  ];
  
  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.ubuntu-mono
      ubuntu-classic
      inter
     ];
  };

  # Font Rendering
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

  # Enable Firefox
  programs.firefox.enable = true;

  # Steam
  programs.steam.enable = true;

  # Game Mode
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
      inhibit_screensaver = 1;
      softrealtime = "auto";
      renice = 10;
     };
     custom = {
      start = "systemd-inhibit --what=idle:sleep --who=GameMode --why='Gaming session active' sleep infinity & echo $! > /tmp/gamemode-inhibit.lock";
      end = "kill $(cat /tmp/gamemode-inhibit.lock)";
    };
  };
};
  
  # Audio Settings
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    extraConfig.pipewire = {
      "98-crackling-fix" = {
        "context-properties" = {
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 1024;
          "default.clock.max-quantum" = 8192;
         };
       };
    };
  };

  security.rtkit.enable = true;

  # Systemd Service For EasyEffects
  systemd.user.services.easyeffects = {
    description = "EasyEffects Daemon";
    requires = [ "dbus.service" ];
    after = [ "pipewire.service" ];
    partOf = [ "pipewire.service" ];
    wantedBy = [ "default.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
      ExecStop = "${pkgs.easyeffects}/bin/easyeffects --quit";
      Restart = "on-failure";
      RestartSec = 5;
    };
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
