let
  zx-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB9pAWo4p4nU2pbRKddNN+kbdyrWTTksVkV+yON0JwJc";
  nodes = {
    tailscale-router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJXN0R3Qxcv0gwFIC7xb5rhi9PTK39TruxoO8MYbkXK";
    docker-stable = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrKQ6XR+8nRDV/KdSB97wjYpyRvufS8u7NvwmBIixGg";
  };
in
{
  "hosts/tailscale-router/secrets/auth-key.age".publicKeys = [ zx-laptop nodes.tailscale-router ];

  "hosts/docker-stable/secrets/base.env.age".publicKeys = [ zx-laptop nodes.docker-stable ];

  "hosts/docker-stable/secrets/myaddr-token.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/traefik-secret.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/traefik.env.age".publicKeys = [ zx-laptop nodes.docker-stable ];

  "hosts/docker-stable/secrets/nextcloud.postgres-db-name.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/nextcloud.postgres-username.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/nextcloud.postgres-password.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/nextcloud.username.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/nextcloud.password.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];

  "hosts/docker-stable/secrets/onlyoffice.env.age".publicKeys = [ zx-laptop nodes.docker-stable ];

  "hosts/docker-stable/secrets/photoprism.mariadb-password.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/photoprism.password.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];

  "hosts/docker-stable/secrets/gitea.postgres-db-name.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/gitea.postgres-username.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/gitea.postgres-password.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/gitea.lfs-jwt-secret.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/gitea.secret-key.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/gitea.jwt-secret.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/gitea.internal-token.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];

  "hosts/docker-stable/secrets/jellyfin.jellystat-postgres-db-name.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/jellyfin.jellystat-postgres-username.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/jellyfin.jellystat-postgres-password.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];
  "hosts/docker-stable/secrets/jellyfin.jellystat-jwt-secret.txt.age".publicKeys = [ zx-laptop nodes.docker-stable ];

  "hosts/docker-stable/secrets/wallabag.env.age".publicKeys = [ zx-laptop nodes.docker-stable ];
}
