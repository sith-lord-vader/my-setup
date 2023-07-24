{ config, lib, pkgs, netmaker, test, elasticsearch, jupyterhub1, ... }:

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
  virtualisation.lxd.enable = true;
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
    extraGroups = [ "networkmanager" "wheel" "docker" "lxd" "rslsync" "nginx" ];
    packages = with pkgs; [
      firefox
      kate
    ];
  };

  users.users.rslsync = {
    extraGroups = [ "shared" ];
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
    #!---misc---

    #*---test pkgs---
    pkgs.test
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

  # jupyterhub-yarnspawner = pkgs.python3Packages.buildPythonPackage rec {
  #   pname = "jupyterhub-yarnspawner";
  #   version = "0.4.0";

  #   src = pkgs.python37Packages.fetchPypi {
  #     inherit version;
  #     inherit pname;
  #     sha256 = "3b82130c81a31981d929012c628feb7d6d7ec98aeba17946f668fe42023c826b";
  #   };

  #   buildInputs = [ pkgs.python3Packages.jupyterhub pkgs.python3Packages.skein ];
  # };

  #!----Jupyterhub----
  services.jupyterhub =
    {
      enable = true;
      spawner = "yarnspawner.YarnSpawner";
      authentication = "dummyauthenticator.DummyAuthenticator";
      jupyterhubEnv = (pkgs.python39.withPackages (pythonPackages: with pythonPackages; [
        jupyterhub
        jupyterhub1.packages.x86_64-linux.skein
        jupyterlab
        (pkgs.python39Packages.buildPythonPackage rec {
          pname = "yarnspawner";
          version = "0.4.0";

          src = pkgs.python39Packages.fetchPypi {
            inherit version;
            pname = "jupyterhub-yarnspawner";
            sha256 = "3b82130c81a31981d929012c628feb7d6d7ec98aeba17946f668fe42023c826b";
          };

          doCheck = false;

          buildInputs = [ pkgs.python39Packages.jupyterhub jupyterhub1.packages.x86_64-linux.skein pkgs.python39Packages.pytest pkgs.python39Packages.notebook pkgs.python39Packages.jupyterlab  ];
        })
        (pkgs.python39Packages.buildPythonPackage rec {
          pname = "dummyauthenticator";
          version = "0.3.1";

          src = pkgs.python39Packages.fetchPypi {
            inherit version;
            pname = "jupyterhub-dummyauthenticator";
            sha256 = "1be23aecd2745a5a24fb41e0bb2cab52f49a1f1e78204ca2c31bb43f486f982a";
          };

          doCheck = false;

          buildInputs = [ pkgs.python39Packages.jupyterhub pkgs.python39Packages.notebook  pkgs.python39Packages.jupyterlab  ];
        })
      ]));
      extraConfig = ''
        c.JupyterHub.hub_ip = '127.0.0.1'
        c.YarnSpawner.debug = True
        c.Authenticator.admin_users = { 'xpert' }
        c.YarnSpawner.localize_files = {
            'environment': 'hdfs:///environments/example.tar.gz'
        }
        c.YarnSpawner.prologue = 'source environment/bin/activate'
      '';
    };
  #!------------------

    # services.jupyterhub =
    # {
    #   enable = true;
    #   port = 8082;
    #   spawner = "yarnspawner.YarnSpawner";
    #   jupyterhubEnv = (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
    #     jupyterhub
    #     (pkgs.python3Packages.buildPythonPackage rec {
    #         pname = "skein";
    #         version = "0.8.2";
    #         src = pkgs.python3Packages.fetchPypi {
    #             inherit pname version;
    #             hash = "sha256-nXTqsJNX/LwAglPcPZkmdYPfF+vDLN+nNdZaDFTrHzE=";
    #         };

    #         # Update this hash if bumping versions
    #         jarHash = "sha256-x2KH6tnoG7sogtjrJvUaxy0PCEA8q/zneuI969oBOKo=";
    #         skeinJar = callPackage ./skeinjar.nix { inherit pname version jarHash; };

    #         propagatedBuildInputs = [ pkgs.python3Packages.cryptography pkgs.python3Packages.grpcio pkgs.python3Packages.pyyaml ];
    #         buildInputs = [ pkgs.python3Packages.grpcio-tools ];

    #         patches = [ ./test.patch ];

    #         preBuild = ''
    #             # Ensure skein.jar exists skips the maven build in setup.py
    #             mkdir -p skein/java
    #             ln -s ${skeinJar} skein/java/skein.jar
    #         '';

    #         postPatch = ''
    #             substituteInPlace skein/core.py --replace "'yarn'" "'${pkgs.hadoop}/bin/yarn'" \
    #             --replace "else 'java'" "else '${pkgs.hadoop.jdk}/bin/java'"
    #         '';

    #         pythonImportsCheck = [ "skein" ];

    #         checkInputs = [ pkgs.python3Packages.pytestCheckHook ];
    #         # These tests require connecting to a YARN cluster. They could be done through NixOS tests later.
    #         disabledTests = [
    #             "test_ui"
    #             "test_tornado"
    #             "test_kv"
    #             "test_core"
    #             "test_cli"
    #         ];

    #         meta = with lib; {
    #             homepage = "https://jcristharif.com/skein";
    #             description = "A tool and library for easily deploying applications on Apache YARN";
    #             license = licenses.bsd3;
    #             maintainers = with maintainers; [ alexbiehl illustris ];
    #             # https://github.com/NixOS/nixpkgs/issues/48663#issuecomment-1083031627
    #             # replace with https://github.com/NixOS/nixpkgs/pull/140325 once it is merged
    #         };
    #     })
    #     jupyterlab
    #     (pkgs.python3Packages.buildPythonPackage rec {
    #       pname = "yarnspawner";
    #       version = "0.4.0";

    #       src = pkgs.python37Packages.fetchPypi {
    #         inherit version;
    #         pname = "jupyterhub-yarnspawner";
    #         sha256 = "3b82130c81a31981d929012c628feb7d6d7ec98aeba17946f668fe42023c826b";
    #       };

    #       doCheck = false;

    #       buildInputs = [ pkgs.python3Packages.jupyterhub (pkgs.python3Packages.buildPythonPackage rec {
    #         pname = "skein";
    #         version = "0.8.2";
    #         src = pkgs.python3Packages.fetchPypi {
    #             inherit pname version;
    #             hash = "sha256-nXTqsJNX/LwAglPcPZkmdYPfF+vDLN+nNdZaDFTrHzE=";
    #         };

    #         # Update this hash if bumping versions
    #         jarHash = "sha256-x2KH6tnoG7sogtjrJvUaxy0PCEA8q/zneuI969oBOKo=";
    #         skeinJar = callPackage ./skeinjar.nix { inherit pname version jarHash; };

    #         propagatedBuildInputs = [ pkgs.python3Packages.cryptography pkgs.python3Packages.grpcio pkgs.python3Packages.pyyaml ];
    #         buildInputs = [ pkgs.python3Packages.grpcio-tools ];

    #         patches = [ ./test.patch ];

    #         preBuild = ''
    #             # Ensure skein.jar exists skips the maven build in setup.py
    #             mkdir -p skein/java
    #             ln -s ${skeinJar} skein/java/skein.jar
    #         '';

    #         postPatch = ''
    #             substituteInPlace skein/core.py --replace "'yarn'" "'${pkgs.hadoop}/bin/yarn'" \
    #             --replace "else 'java'" "else '${pkgs.hadoop.jdk}/bin/java'"
    #         '';

    #         pythonImportsCheck = [ "skein" ];

    #         checkInputs = [ pkgs.python3Packages.pytestCheckHook ];
    #         # These tests require connecting to a YARN cluster. They could be done through NixOS tests later.
    #         disabledTests = [
    #             "test_ui"
    #             "test_tornado"
    #             "test_kv"
    #             "test_core"
    #             "test_cli"
    #         ];

    #         meta = with lib; {
    #             homepage = "https://jcristharif.com/skein";
    #             description = "A tool and library for easily deploying applications on Apache YARN";
    #             license = licenses.bsd3;
    #             maintainers = with maintainers; [ alexbiehl illustris ];
    #             # https://github.com/NixOS/nixpkgs/issues/48663#issuecomment-1083031627
    #             # replace with https://github.com/NixOS/nixpkgs/pull/140325 once it is merged
    #         };
    #     }) pkgs.python3Packages.pytest pkgs.python3Packages.notebook pkgs.python3Packages.jupyterhub pkgs.python3Packages.jupyterlab ];
    #     })
    #   ]));
    #   extraConfig = ''
    #     c.JupyterHub.hub_ip = '127.0.0.1'
    #     c.YarnSpawner.debug = True
    #     c.Authenticator.admin_users = { 'xpert' }
    #     c.YarnSpawner.localize_files = {
    #         'environment': 'hdfs:///environments/example.tar.gz'
    #     }
    #     c.YarnSpawner.prologue = 'source environment/bin/activate'
    #   '';
    # };

security.pam.services."jupyterhub".setLoginUid = true;

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

  services.darth-vader = {
    enable = true;
    port = "8002";
  };

  services.resilio = {
    enable = true;
    httpListenPort = 6969;
    enableWebUI = true;
  };

  services.nginx = {
    enable = true;
    group = "nginx";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    # upstreams.adc-data-es-upstreams.servers = {
    #   "172.20.32.183:9200" = {};
    #   "172.20.32.184:9200" = {};
    #   "172.20.32.185:9200" = {};
    # };

    virtualHosts."resilio.xpert-nixos-local.vader" = {
      addSSL = true;
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }
        {
          addr = "0.0.0.0";
          port = 80;
        }
      ];
      sslCertificate = "/etc/MyCert.crt";
      sslCertificateKey = "/etc/MyPrivate.key";
      locations."/" = {
        proxyPass = "http://localhost:6969";
      };
    };

    virtualHosts."resilio.xpert-nixos.vader" = {
      addSSL = true;
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }
        {
          addr = "0.0.0.0";
          port = 80;
        }
      ];
      sslCertificate = "/etc/MyCertMain.crt";
      sslCertificateKey = "/etc/MyPrivate.key";
      locations."/" = {
        proxyPass = "http://localhost:6969";
      };
    };
  };

  programs.nix-ld.enable = true;
  environment.variables = {
      NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
        pkgs.stdenv.cc.cc
      ];
      NIX_LD = lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  };

  services.hadoop = {
    hdfs.namenode.enable = true;
    hdfs.datanode.enable = true;
    yarn.nodemanager.enable = true;
    yarn.resourcemanager.enable = true;
    coreSite = {
    "fs.defaultFS" = "hdfs://127.0.0.1:9000";
    "yarn.scheduler.capacity.root.queues" = "default";
    "yarn.scheduler.capacity.root.default.capacity" = 100;
    "hadoop.proxyuser.jupyterhub.hosts" = "*";
    "hadoop.proxyuser.jupyterhub.groups" = "*";
    "hadoop.proxyuser.root.hosts" = "*";
    "hadoop.proxyuser.root.groups" = "*";
    }; 
    hdfsSite = { 
    "dfs.replication" = 1;
        };
    yarnSite = {
    "yarn.nodemanager.hostname" = "127.0.0.1"; 
    "yarn.resourcemanager.hostname" = "127.0.0.1";
    "yarn.nodemanager.aux-services" = "mapreduce_shuffle";
    "yarn.acl.enable" = 0;
    };
    mapredSite = {
    "mapreduce.framework.name" = "yarn";
    "yarn.app.mapreduce.am.env" = "HADOOP_MAPRED_HOME=$HADOOP_HOME";
    "mapreduce.map.env" = "HADOOP_MAPRED_HOME=$HADOOP_HOME";
    "mapreduce.reduce.env" = "HADOOP_MAPRED_HOME=$HADOOP_HOME";

    };
  };

  security.pki.certificateFiles = [ "/home/xpert/.my-setup/OpenWrt.pem" "/etc/CAPrivate.pem" ];

  # services.kibana8 = {
  #   enable = true;
  #   package = elasticsearch.packages.x86_64-linux.kibana8;
  #   listenAddress = "0.0.0.0";
  #   elasticsearch.hosts = ["http://172.20.32.183:9200" "http://172.20.32.184:9200" "http://172.20.32.185:9200"];
  # };

  system.stateVersion = "22.05";
}
