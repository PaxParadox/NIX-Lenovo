# Media Module (Placeholder)
#
# Future module for media applications.
# Examples: mpv, vlc, spotify, etc.
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.myModules.media;
in {
  options.myModules.media = {
    enable = mkEnableOption "media applications";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      qbittorrent
      tidal-hifi
    ];
  };
}
