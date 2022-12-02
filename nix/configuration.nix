{ config, pkgs, bulla, gitit-wiki, test, ... }:

{
  imports =
    [
      ./machine/mnet.nix
    ];

  nixpkgs.overlays = [
    (_: _: { bulla-agent = bulla.defaultPackage.x86_64-linux; test = test.defaultPackage.x86_64-linux; gitit-wiki = gitit-wiki.defaultPackage.x86_64-linux; })
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
  networking.extraHosts =
    ''
      172.16.0.1 lord.vader
      172.16.0.100 nitro-5-win.vader
      172.16.0.101 nixos.vader
      172.16.0.102 abhishek-s22.vader
      172.16.0.110 kartos.vader
      172.16.0.120 oldmonk.vader
    '';
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
    discord
    docker
    anydesk
    openssl
    wakatime
    neofetch
    pkgs.bulla-agent
    pkgs.gitit-wiki
    pkgs.test
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

  services.stormtrooper = {
    enable = true;
    hostname = "nixos";
    address = "0.0.0.0";
    port = "9999";
  };
  services.gitit-wiki.enable = true;

  services.pkg_name =
    {
      enable = true;
      example_option = "Please visit lordvader.me";
    }

      #*----Firewall----
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      networking.firewall.enable = false;
  #!----Firewall----

  system.stateVersion = "22.05";
}
