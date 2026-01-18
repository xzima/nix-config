{
  inputs,
  nixpkgsConfig,
  ...
}: final: prev: {
  unstable = import inputs.nixpkgs-unstable {
    system = final.system;
    config = nixpkgsConfig;
  };
}
