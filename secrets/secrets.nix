let
  zx-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB9pAWo4p4nU2pbRKddNN+kbdyrWTTksVkV+yON0JwJc";
  nodes = {
    tailscale-router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3cZDLq//jXB+VCqAHtAlKL5nzifN/tx3QFlDgOvV93";
    docker-stable = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrKQ6XR+8nRDV/KdSB97wjYpyRvufS8u7NvwmBIixGg";
  };
in
{
  "node/tailscale-router/auth-key.age".publicKeys = [ zx-laptop nodes.tailscale-router ];
  "node/docker-stable/myaddr-token.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "node/docker-stable/traefik-secret.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "node/docker-stable/base.env.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "node/docker-stable/traefik.env.age".publicKeys = [ zx-laptop nodes.docker-stable ];
}

