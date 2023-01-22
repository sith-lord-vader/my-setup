{ config, pkgs, test, elasticsearch, ... }:

{
  imports =
    [
      ./machine/mnet.nix
      ./modules/wireguard.nix
    ];

  nixpkgs.overlays = [
    (_: _: { test = test.defaultPackage.x86_64-linux; })
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  virtualisation.docker.enable = true;
  services.flatpak.enable = true;

  #*----Bootloader----
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    devices = [ "nodev" ];
    enable = true;
    version = 2;
    useOSProber = true;
    efiSupport = true;
  };
  #!----Bootloader----

  #*----Networking----
  networking.hostName = "nixos";
  # networking.wireless.enable = true;
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.networkmanager.enable = true;
  networking.domain = "vader";
  # networking.extraHosts =
  #   ''
  #     172.16.0.1 lord.vader
  #     172.16.0.100 nitro-5-win.vader
  #     172.16.0.101 nixos.vader
  #     172.16.0.102 abhishek-s22.vader
  #     172.16.0.110 kartos.vader
  #     172.16.0.120 oldmonk.vader
  #   '';
  #!----Networking----

  #*----General Settings----
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_IN";
  services.printing.enable = true;
  #!----General Settings----

  #*----Desktop Settings----
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };
  # services.xserver.libinput.enable = true;
  #!----Desktop Settings----  

  #*----Sound Settings----
  services.blueman.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
    #media-session.enable = true;
  };
  #!----Sound Settings----


  #*----User Account----
  users.users.xpert = {
    isNormalUser = true;
    description = "Abhishek Adhikari";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox
      kate
    ];
  };
  #!----User Account----

  #*----Fonts----
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "Hack" ]; })
  ];
  #!----Fonts----

  #*----System Packages----
  environment.systemPackages = with pkgs; [
    #*---work---
    wget
    git
    google-chrome
    vscode
    python3
    bitwarden
    bitwarden-cli
    home-manager
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    oh-my-zsh
    openvpn
    docker
    anydesk
    openssl
    wakatime
    neofetch
    wireguard-tools
    ksshaskpass
    #!---work---

    #*---misc---
    discord
    obs-studio
    ffmpeg
    yt-dlp
    mpv
    vlc
    #!---misc---

    #*---test pkgs---
    pkgs.test
    #!---test pkgs---
  ];
  #!----System Packages----

  #*----OpenVPN Setup----
  environment.etc.openvpn.source = "${pkgs.update-resolv-conf}/libexec/openvpn";
  #!----OpenVPN Setup

  #*----SSH Setup----
  programs.ssh.startAgent = true;
  services.openssh.enable = true;
  #!----SSH Setup

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  #*----User Access Settings----
  # services.fprintd.enable = true;
  # security.pam.services.login.fprintAuth = true;
  security.sudo.wheelNeedsPassword = false;
  services.gnome.gnome-keyring.enable = true;
  #!----User Access Settings----

  services.pkg_name =
    {
      enable = false;
      example_option = "Please visit lordvader.me";
    };

  #*----Firewall----
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = false;
  #!----Firewall----

  services.jupyterhub =
    {
      enable = true;
    };

  #*---settings node-exporter---
  services.prometheus =
    {
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
      };
    };
  #!---settings node-exporter---

  services.stormtrooper = {
    enable = true;
    hostname = "nixos";
    address = "0.0.0.0";
    port = "9999";
  };

  services.elasticsearch = {
    enable = true;
    listenAddress = "127.0.0.1";
    single_node = false;
    package = elasticsearch.packages.x86_64-linux.elasticsearch8;
    extraConf = ''
      node.name: "es-1"
      node.master: true
      node.data: false
      discovery.zen.ping.unicast.hosts: ["127.0.0.1"]
    '';
  };

  services.darth-vader = {
    enable = true;
    port = "8002";
  };

  security.pki.certificateFiles = [ "/home/xpert/.my-setup/OpenWrt.pem" ];

  system.stateVersion = "22.05";
}
