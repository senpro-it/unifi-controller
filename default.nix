{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.senpro.oci-containers.unifi-controller;

in

{

  options = {
    senpro.oci-containers.unifi-controller.traefik.fqdn = mkOption {
      type = types.str;
      default = "unifi.local";
      example = "unifi.example.com";
      description = ''
        Defines the FQDN under which the predefined container endpoint should be reachable.
      '';
    };
  };

  config = {
    virtualisation.oci-containers.containers = {
      unifi-controller = {
        image = "lscr.io/linuxserver/unifi-controller:latest";
        ports = [
          "1900:1900/udp" "[::]:1900:1900/udp"
          "3478:3478/udp" "[::]:3478:3478/udp"
          "6789:6789/tcp" "[::]:6789:6789/tcp"
          "8080:8080/tcp" "[::]:8080:8080/tcp"
          "10001:10001/udp" "[::]:10001:10001/udp"
        ];
        extraOptions = [
          "--net=proxy"
        ];
        volumes = [
          "unifi-controller:/config"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          MEM_LIMIT = "1024M";
          MEM_STARTUP = "1024M";
        };
        autoStart = true;
      };
    };
    systemd.services = {
      "podman-unifi-controller" = {
        postStart = ''
          ${pkgs.coreutils-full}/bin/printf '%s\n' "http:" \
          "  routers:"   \
          "    unifi-controller:" \
          "      rule: \"Host(\`${cfg.traefik.fqdn}\`)\"" \
          "      service: \"unifi-controller\"" \
          "      entryPoints:" \
          "      - \"https2-tcp\"" \
          "      tls: true" \
          "  services:" \
          "    unifi-controller:" \
          "      loadBalancer:" \
          "        passHostHeader: true" \
          "        servers:" \
          "        - url: \"https://unifi-controller:8443\"" \
          "        serversTransport: \"unifi-controller\"" \
          "  serversTransports:" \
          "    unifi-controller:" \
          "      serverName: \"${cfg.traefik.fqdn}\"" \
          "      insecureSkipVerify: true" > $(${pkgs.podman}/bin/podman volume inspect traefik --format "{{.Mountpoint}}")/conf.d/apps-unifi-controller.yml
        '';
      };
    };
  };

}
