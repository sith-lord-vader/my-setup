{ config, lib, pkgs, modulesPath, ... }:

{
  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "172.16.0.101/24" ];

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/home/xpert/wireguard-keys/private";

      peers = [
        {
          publicKey = "<public_key>";

          allowedIPs = [ "172.16.0.0/24" ];

          endpoint = "<ip/hostname>:<port>";

          persistentKeepalive = 25;
        }
      ];
    };
  };
}
