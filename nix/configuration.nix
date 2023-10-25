{ config, lib, pkgs, home-manager, vscode-server, ... }:

{
  imports =
    [
      ./machine/mnet.nix
      #./modules/wireguard.nix
      home-manager.nixosModules.home-manager
      vscode-server.nixosModules.default
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  virtualisation.docker.enable = true;
  virtualisation.lxd.enable = true;
  services.flatpak.enable = true;
  services.vscode-server.enable = true;

  #*----Bootloader----
  boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.efi.efiSysMountPoint = "/boot/efi";
  #boot.loader.grub = {
  #  devices = [ "nodev" ];
  #  enable = true;
  #  useOSProber = true;
  #  efiSupport = true;
  #};
  #!----Bootloader----

  #*----Networking----
  networking.hostName = "death-star";
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
    extraGroups = [ "networkmanager" "wheel" "docker" "lxd" "rslsync" "nginx" ];
    packages = with pkgs; [
    ];
  };

  home-manager.users.xpert = {
    home.stateVersion = "23.05";
    home.username = "xpert";
    home.homeDirectory = "/home/xpert";
    programs.home-manager.enable = true;

    programs = {
      zsh = {
        enable = true;
        enableCompletion = false; # enabled in oh-my-zsh
        initExtra = ''
          autoload -U up-line-or-beginning-search
          autoload -U down-line-or-beginning-search
          zle -N up-line-or-beginning-search
          zle -N down-line-or-beginning-search
          bindkey "''${key[Up]}" up-line-or-beginning-search
          bindkey "''${key[Down]}" down-line-or-beginning-search
          bindkey "''${key[Up]}" up-line-or-search
          test -f ~/.dir_colors && eval $(dircolors ~/.dir_colors)
          #neofetch
          [ -z "$SSH_AUTH_SOCK" ] && eval "$(ssh-agent -s)"

          sudo () {
            local command=$@
            if [[ "$command" =~ -y ]]; then
              command sudo "$@"
            else
              read -r "REPLY?Authorize command $(echo \"$@\") be  executed? (y/N): "
              if [[ "$REPLY" = [yY]* ]]; then
                command sudo "$@"
              else
                return $?
              fi
            fi
          }

          export PATH=$HOME/.my-setup/bin:$PATH
          alias ssh="ssh -A"

          source $HOME/.bitwarden-keys.sh
          setup_bitwarden
          export BW_SESSION=$(bw unlock --passwordenv BW_MASTER --raw)
        '';
        shellAliases = {
          ne = "nix-env";
          ni = "nix-env -iA";
          no = "nixops";
          ns = "nix-shell --pure";
          please = "sudo";
          cls = "clear";
        };
        zplug = {
          enable = true;
          plugins = [
            { name = "zsh-users/zsh-autosuggestions"; }
            { name = "zsh-users/zsh-syntax-highlighting"; }
            { name = "zdharma-continuum/fast-syntax-highlighting"; }
            { name = "marlonrichert/zsh-autocomplete"; tags = [ depth:1 ]; }
          ];
        };
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "python" "vscode" "docker" ];
          theme = "agnoster";
        };
      };
    };
  };

  #!----User Account----

  #*----Fonts----
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "Hack" "Meslo" ]; })
  ];
  #!----Fonts----

  #*----System Packages----
  environment.systemPackages = with pkgs; [
    #*---work---
    exfat
    wget
    expect
    git
    google-chrome
    vscode
    python3
    openvpn
    bitwarden-cli
    docker
    anydesk
    openssl
    wakatime
    neofetch
    wireguard-tools
    ksshaskpass
    inetutils
    terraform
    # netmaker.packages.x86_64-linux.netmaker
    #!---work---

    #*---misc---
    hollywood
    discord
    obs-studio
    ffmpeg
    yt-dlp
    mpv
    vlc
    keystore-explorer
    guake
    cool-retro-term
    logseq
    spotify
    spotify-tray
    #!---misc---

    #*---test pkgs---
    #pkgs.test
    # elasticsearch.packages.x86_64-linux.elasticsearch8
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
  #services.fprintd.enable = false;
  #security.pam.services.login.fprintAuth = false;
  security.sudo.wheelNeedsPassword = false;
  services.gnome.gnome-keyring.enable = true;
  #!----User Access Settings----

  #*----Firewall----
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = false;
  #!----Firewall----

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

  programs.nix-ld.enable = true;
  #environment.variables = {
  #    NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
  #      pkgs.stdenv.cc.cc
  #    ];
  #    #NIX_LD = lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  #};

  environment.shells = with pkgs; [ zsh ];

  #security.pki.certificateFiles = [ "/home/xpert/.my-setup/OpenWrt.pem" "/etc/CAPrivate.pem" ];

  system.stateVersion = "23.05";
}
