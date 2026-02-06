{
  inputs,
  nixpkgsConfig,
  ...
}: [
  inputs.zed-extensions.overlays.default
  inputs.niri.overlays.niri
  (import ./jetbrains.nix)
  (import ./yazi-clipboard.nix)
  (import ./unstable-packages.nix {inherit inputs nixpkgsConfig;})
]
