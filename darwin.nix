{
  inputs,
  username,
  homeDirectory,
  ...
}:
{
  imports = [
    (inputs.core + /modules/core.nix)
    (inputs.core + /modules/system/darwin-homebrew.nix)
    (inputs.core + /modules/system/darwin-defaults.nix)
    # Optional per host:
    # (inputs.core + /modules/system/darwin-limits.nix)
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;

  users.users.${username}.home = homeDirectory;
}

