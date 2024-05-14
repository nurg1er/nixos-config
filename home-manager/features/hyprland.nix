{ pkgs, ... }: {

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.package = pkgs.unstable.hyprland;
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    "$alt_mod" = "ALT";
    "monitor" = "eDP-1,2560x1600@96,0x0,1.6";

    env = [
      "NIXOS_OZONE_WL, 1"
	  "XDG_CURRENT_DESKTOP, Hyprland"
	  "XDG_SESSION_TYPE, wayland"
	  "XDG_SESSION_DESKTOP, Hyprland"
	  "WLR_DRM_DEVICES,/dev/dri/card0"
	  "QT_QPA_PLATFORMTHEME, qt6ct"
    ];

    xwayland = {
      force_zero_scaling = true;
    };

    gestures = {
      workspace_swipe = true;
    };

    bind = [
      # basics
      "$mod, RETURN, exec, alacritty"
	  "$mod, C, killactive"
	  "$mod, M, exit"

  	  # navigation
  	  "$mod, left, movefocus, l"
	  "$mod, right, movefocus, r"
	  "$mod, up, movefocus, u"
	  "$mod, down, movefocus, d"
	  "$mod, h, movefocus, l"
	  "$mod, l, movefocus, r"
	  "$mod, k, movefocus, u"
	  "$mod, j, movefocus, d"

  	  "$mod SHIFT, left, movewindow, l"
  	  "$mod SHIFT, right, movewindow, r"
	  "$mod SHIFT, up, movewindow, u"
	  "$mod SHIFT, down, movewindow, d"
	  "$mod SHIFT, h, movewindow, l"
	  "$mod SHIFT, l, movewindow, r"
	  "$mod SHIFT, k, movewindow, u"
	  "$mod SHIFT, j, movewindow, d"

  	  "$mod, Tab, cyclenext,"
  	  "$mod, Tab, bringactivetotop,"

      "$alt_mod, Tab, workspace, e+1"

    ]
    ++ (
      # workspaces
      # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
      builtins.concatLists (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 10;
          in
            builtins.toString (x + 1 - (c * 10));
        in [
          "$mod, ${ws}, workspace, ${toString (x + 1)}"
          "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
        ]
      )
      10)
    );
  };
}