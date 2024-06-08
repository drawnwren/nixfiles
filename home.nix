{config, pkgs, ...}:

{
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "drawnwren";
    userEmail = "drawnwren@gmail.com";
    extraConfig = {
    	safe = { directory = "/etc/nixos"; };
    };
  };
  xdg.mimeApps.defaultApplications = {
    "text/plain" = [ "neovide.desktop" ];
    "applications/pdf" = [ "zathura.desktop" ];
    "image/*" = [ "sxiv.desktop" ];
    "video/png" = [ "mpv.desktop" ];
    "video/jpg" = [ "mpv.desktop" ];
    "video/*" = [ "mpv.desktop" ];
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    # initExtra = (builtins.readFile ./config/zsh/.zshrc);
  };

  programs.chromium = {
  	enable = true;
	package = pkgs.ungoogled-chromium;
  };
    
  home.stateVersion = "24.05";
}
