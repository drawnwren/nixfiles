{
  pkgs,
  repos,
  ...
}: let
  wrenPkg = repos.wren.packages.${pkgs.stdenv.hostPlatform.system}.wren;
in {
  home.packages = [wrenPkg];
  programs.zsh.shellAliases.w = pkgs.lib.getExe' wrenPkg "wren";
}
