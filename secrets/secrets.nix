let
  zx-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB9pAWo4p4nU2pbRKddNN+kbdyrWTTksVkV+yON0JwJc";
  nodes = {
    tailscale-router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3cZDLq//jXB+VCqAHtAlKL5nzifN/tx3QFlDgOvV93";
  };
in
{
  "node/tailscale-router/auth-key.age".publicKeys = [ zx-laptop nodes.tailscale-router ];
}

