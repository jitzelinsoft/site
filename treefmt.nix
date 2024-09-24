{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.prettier = {
    enable = true;
    settings = {
      useTabs = true;
      tabWidth = 1;
      parser = "html";
    };
  };
}
