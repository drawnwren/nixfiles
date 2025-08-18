{ pkgs, ... }:

{
  # Script to handle GPU switching
  environment.systemPackages = [
    (pkgs.writeScriptBin "hdmi-gpu-switch" ''
      #!${pkgs.bash}/bin/bash
      
      HDMI_STATUS=$(cat /sys/class/drm/card1-HDMI-A-1/status 2>/dev/null)
      USER="barbatos"
      
      if [ "$HDMI_STATUS" = "connected" ]; then
        echo "HDMI connected, switching to NVIDIA GPU priority"
        # Set NVIDIA as primary GPU for rendering
        echo "WLR_DRM_DEVICES=/dev/dri/card1:/dev/dri/card2" > /tmp/gpu-env
        
        # If Hyprland is running, restart it with new GPU config
        if pgrep -x "Hyprland" > /dev/null; then
          sudo -u $USER systemctl --user restart hyprland-session.service 2>/dev/null || \
          sudo -u $USER bash -c "pkill Hyprland; sleep 1; WLR_DRM_DEVICES=/dev/dri/card1:/dev/dri/card2 Hyprland &"
        fi
      else
        echo "HDMI disconnected, switching to AMD GPU priority"
        # Set AMD as primary GPU for better battery life
        echo "WLR_DRM_DEVICES=/dev/dri/card2:/dev/dri/card1" > /tmp/gpu-env
        
        if pgrep -x "Hyprland" > /dev/null; then
          sudo -u $USER systemctl --user restart hyprland-session.service 2>/dev/null || \
          sudo -u $USER bash -c "pkill Hyprland; sleep 1; WLR_DRM_DEVICES=/dev/dri/card2:/dev/dri/card1 Hyprland &"
        fi
      fi
    '')
  ];

  # Udev rule for HDMI hotplug
  services.udev.extraRules = ''
    # Detect HDMI plug/unplug events on NVIDIA GPU
    ACTION=="change", KERNEL=="card1", SUBSYSTEM=="drm", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/barbatos/.Xauthority", RUN+="${pkgs.bash}/bin/bash -c '${pkgs.systemd}/bin/systemctl start hdmi-gpu-switch.service'"
  '';

  # SystemD service to run the switch script
  systemd.services.hdmi-gpu-switch = {
    description = "Switch GPU based on HDMI connection";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/hdmi-gpu-switch";
      StandardOutput = "journal";
    };
  };
}