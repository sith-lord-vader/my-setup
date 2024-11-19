{ config, lib, pkgs, home-manager, vscode-server, pkgs-extras, certify-rebellion, cloudflare-warp, ... }:

{
  imports = let

  in [
    ./machine/mnet.nix
    #./modules/wireguard.nix
    home-manager.nixosModules.home-manager
    vscode-server.nixosModules.default
    certify-rebellion.nixosModules.certify-rebellion
    cloudflare-warp.nixosModules.cloudflare-warp
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [ "electron" "electron-27.3.11" ];

  virtualisation.docker.enable = true;
  virtualisation.lxd.enable = true;
  services.flatpak.enable = true;
  services.vscode-server.enable = true;

  #*----Bootloader----
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  boot.kernelModules = [
    "evdi"
  ];

  programs.cloudflare-warp.enable = true;
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
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
#   services.xserver.config = ''
# Section "ServerLayout"
#   Identifier   "Main"
#   Screen       0 "Primary"
#   Screen       1 "DellPortraitLeft" RightOf "Primary"
#   Screen       2 "Wacom" RightOf "DellPortraitLeft"
#   Screen       3 "U2412" LeftOf "Primary"
#   Option         "Xinerama" "1"  # enable XINERAMA extension.  Default is disabled.
# EndSection  
#   '';
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };
  # services.hardware.bolt.enable = true;
  # services.xserver.libinput.enable = true;
  #!----Desktop Settings----  

  #*----Sound Settings----
  services.blueman.enable = true;
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

  networking.nameservers = [ "10.0.0.1" ];

  #*----User Account----
  users.users.xpert = {
    isNormalUser = true;
    description = "Abhishek Adhikari";
    extraGroups = [ "networkmanager" "wheel" "docker" "lxd" "rslsync" "nginx" ];
    packages = with pkgs; [ ];
  };

  # programs.weylus = {
  #   enable = true;
  #   users = [ "xpert" ];
  #   openFirewall = true;
  # };

  home-manager.users.xpert = {
    home.stateVersion = "23.05";
    home.username = "xpert";
    home.homeDirectory = "/home/xpert";
    home.enableNixpkgsReleaseCheck = false;
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

          # source $HOME/.bitwarden-keys.sh
          # setup_bitwarden
          # export BW_SESSION=$(bw unlock --passwordenv BW_MASTER --raw)
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
            {
              name = "marlonrichert/zsh-autocomplete";
              tags = [ "depth:1" ];
            }
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
  fonts.packages = with pkgs;
    [ (nerdfonts.override { fonts = [ "FiraCode" "Hack" "Meslo" ]; }) ];
  #!----Fonts----

  #*----System Packages----
  environment.systemPackages = with pkgs; [
    #*---work---
    exfat
    wget
    plasma5Packages.plasma-thunderbolt
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
    nodejs_20
    gnupg
    tmux-cssh
    nixpkgs-fmt
    outils
    pkgs-extras.elasticsearch8
    tmux
    nixfmt-rfc-style
    # netmaker.packages.x86_64-linux.netmaker
    #!---work---

    #*---misc---
    rustdesk
    rustdesk-server
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
    pinentry
    libsForQt5.kcalc
    zoom-us
    zenith
    figma-linux
    figma-agent
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

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  #*----Firewall----
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = false;
  #!----Firewall----

  #*---settings node-exporter---
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
  };
  #!---settings node-exporter---

  services.grafana = {
    enable = true;
    settings = { server = { }; };
  };

  programs.nix-ld.enable = true;
  environment.variables = {
    #  NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
    #    pkgs.stdenv.cc.cc
    #  ];
    #  #NIX_LD = lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
    PLASMA_USE_QT_SCALING=1;
    QT_SCREEN_SCALE_FACTORS="eDP-1=1.25;DVI-I-2-2=1;DVI-I-1-1=1";
  };

  environment.shells = with pkgs; [ zsh ];

  #security.pki.certificateFiles = [ "/home/xpert/.my-setup/OpenWrt.pem" "/etc/CAPrivate.pem" ];

  system.stateVersion = "23.05";

  # services.haproxy = {
  #   enable = true;
  #   config = "";
  # };

  # environment.etc.haproxy.source = "/home/xpert/haproxy.conf";

  # systemd.services.haproxy.serviceConfig = {
  #   ExecStartPre = lib.mkForce [
  #     # when the master process receives USR2, it reloads itself using exec(argv[0]),
  #     # so we create a symlink there and update it before reloading
  #     "${pkgs.coreutils}/bin/ln -sf ${
  #       lib.getExe pkgs.haproxy
  #     } /run/haproxy/haproxy"
  #     # when running the config test, don't be quiet so we can see what goes wrong
  #     "/run/haproxy/haproxy -c -f /etc/haproxy"
  #   ];
  #   ExecStart = lib.mkForce
  #     "/run/haproxy/haproxy -Ws -f /etc/haproxy -p /run/haproxy/haproxy.pid";
  #   ExecReload = lib.mkForce [
  #     "${lib.getExe pkgs.haproxy} -c -f /etc/haproxy"
  #     "${pkgs.coreutils}/bin/ln -sf ${
  #       lib.getExe pkgs.haproxy
  #     } /run/haproxy/haproxy"
  #     "${pkgs.coreutils}/bin/kill -USR2 $MAINPID"
  #   ];
  #   ProtectHome = lib.mkForce "read-only";
  # };

  services.elasticsearch = {
    enable = true;
    listenAddress = "0.0.0.0";
    single_node = false;
    package = pkgs-extras.elasticsearch8;
    cluster_name = "es";
    # restartIfChanged = false;
    plugins = [ ];

    extraConf = ''
      discovery.seed_hosts: ["127.0.0.1"]
      node.name: es-1
      node.roles: [ master, data ]
      node.processors: 2
      cluster.initial_master_nodes: ["es-1"]
      http.cors.enabled: true
      http.cors.allow-origin: '*'
      thread_pool.search.queue_size: 600
      xpack.security.enabled: false
      xpack.security.transport.ssl.enabled: false
      xpack.security.http.ssl.enabled: false
      reindex.remote.whitelist: "apps.dakh.tech:80"
    '';

    extraJavaOptions = [
      "-Xmx4G"
      "-Xms4G"

      # "-XX:-UseConcMarkSweepGC"
      # "-XX:-UseCMSInitiatingOccupancyOnly"
      "-XX:+UseG1GC"
      "-XX:InitiatingHeapOccupancyPercent=75"

      "-Des.networkaddress.cache.ttl=60"
      "-Des.networkaddress.cache.negative.ttl=10"

      "-XX:-HeapDumpOnOutOfMemoryError"
      "-XX:HeapDumpPath=/dev/null"

      "-XX:ErrorFile=/var/log/elasticsearch/hs_err_pid%p.log"

      "-XX:+PreserveFramePointer"

      # "-Xlog:gc*,gc+age=trace,safepoint:file=/var/log/elasticsearch/logs/gc.log:utctime,pid,tags:filecount=32,filesize=64m"
    ];
  };

  services.jupyterhub = {
    enable = true;
    extraConfig = ''
c.Application.log_level = 'DEBUG'
c.Authenticator.allow_all = True
    '';
  };

  # services.certify-rebellion = {
  #   enable = false;
  #   domains = [ "*.srv.media.net" "*.media.net" "*.internal.reports.mn" ];
  # };
}
