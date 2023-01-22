{ config, lib, pkgs, modulesPath, ... }:

{
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "172.16.0.101/24" ];
      dns = [ "172.16.0.1" "vader" ];
      privateKeyFile = "/home/xpert/wireguard-keys/private";


      peers = [
        {
          publicKey = "vRc4CjH7bmHJ0Z6FPUdRO9541yLV8X3UZ11gapE7w2w=";

          allowedIPs = [ "172.16.0.0/24" ];

          endpoint = "172.105.47.207:33333";

          persistentKeepalive = 25;
        }
      ];
    };
  };

  # networking.wireguard.interfaces = {
  #   # "wg0" is the network interface name. You can name the interface arbitrarily.
  #   wg0 = {
  #     # Determines the IP address and subnet of the client's end of the tunnel interface.
  #     ips = [ "172.16.0.101/24" ];

  #     # Path to the private key file.
  #     #
  #     # Note: The private key can also be included inline via the privateKey option,
  #     # but this makes the private key world-readable; thus, using privateKeyFile is
  #     # recommended.
  #     privateKeyFile = "/home/xpert/wireguard-keys/private";

  #     peers = [
  #       {
  #         publicKey = "vRc4CjH7bmHJ0Z6FPUdRO9541yLV8X3UZ11gapE7w2w=";

  #         allowedIPs = [ "172.16.0.0/24" ];

  #         endpoint = "172.105.47.207:33333";

  #         persistentKeepalive = 25;
  #       }
  #     ];
  #   };
  # };
}
