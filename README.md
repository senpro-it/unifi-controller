# unifi-controller
Configuration snippet for NixOS to spin up a unifi-controller container using Podman.

## :tada: `Getting started`

Clone the repository into the directory `/srv/podman/unifi-controller`. The path can't be changed for now!

Add the following statement to your `imports = [];` in `configuration.nix` and do a `nixos-rebuild`:

```
/srv/podman/unifi-controller/default.nix {
  senpro.oci-containers.unifi-controller.traefik.fqdn = "<your-fqdn>";
}
```
