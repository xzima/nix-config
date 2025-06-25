let
  zx-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB9pAWo4p4nU2pbRKddNN+kbdyrWTTksVkV+yON0JwJc";
  sandbox-node = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILoO4xBAsxtedUrmpdvAukMFOoBBS93DDdvtj8tjl4un";
in
{
  "node/sandbox/domain.env.age".publicKeys = [ zx-laptop sandbox-node ];
  "node/sandbox/token.txt.age".publicKeys = [ zx-laptop sandbox-node ];
}

