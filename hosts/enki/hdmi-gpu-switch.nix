{pkgs, ...}: {
  programs.hyprland.package = pkgs.hyprland.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        mkdir -p $out/libexec

        cat > $out/libexec/hypr-gpu-env << 'EOF'
        #!/usr/bin/env bash
        set -euo pipefail
        shopt -s nullglob

        card_by_vendor() {
          local vid="$1"
          for c in /sys/class/drm/card*; do
            if [ -r "$c/device/vendor" ] && grep -qi "$vid" "$c/device/vendor"; then
              basename "$c"; return 0
            fi
          done
          return 1
        }

        bypath_for_card() {
          local card="$1"
          [ -n "$card" ] || { echo -n ""; return; }
          local devdir="/sys/class/drm/$card/device"
          local pci="$(basename "$(readlink -f "$devdir")")"  # e.g. 0000:01:00.0
          local bypath="/dev/dri/by-path/pci-$pci-card"
          if [ -e "$bypath" ]; then
            printf "%s" "$bypath"
          else
            printf "/dev/dri/%s" "$card"
          fi
        }

        ncard="$(card_by_vendor 0x10de || true)"  # NVIDIA
        acard="$(card_by_vendor 0x1002 || true)"  # AMD

        ndev="$(bypath_for_card "$ncard")"
        adev="$(bypath_for_card "$acard")"

        n_connected=0
        if [ -n "''${ncard:-}" ]; then
          for conn in /sys/class/drm/''${ncard}-HDMI-A-* /sys/class/drm/''${ncard}-DP-*; do
            [ -e "$conn/status" ] || continue
            if grep -q "connected" "$conn/status"; then
              n_connected=1; break
            fi
          done
        fi

        if [ "$n_connected" -eq 1 ]; then
          export WLR_DRM_DEVICES="''${ndev}:''${adev}"
        else
          export WLR_DRM_DEVICES="''${adev}:''${ndev}"
        fi
        EOF
        chmod +x $out/libexec/hypr-gpu-env

        wrapProgram $out/bin/Hyprland \
          --set-default WLR_RENDERER vulkan \
          --set-default WLR_NO_HARDWARE_CURSORS 1 \
          --set-default __GL_GSYNC_ALLOWED 0 \
          --set-default __GL_VRR_ALLOWED 0 \
          --run "$out/libexec/hypr-gpu-env"
      '';
  });

  home-manager.users.barbatos = {...}: {
    wayland.windowManager.hyprland.settings.bind = [
      "SUPER SHIFT, E, exit"
    ];
  };
}
