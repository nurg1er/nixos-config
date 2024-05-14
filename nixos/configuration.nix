# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;

      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # FIXME: Add the rest of your current configuration
  # Boot
  # Use systemd bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Blacklist nouveau, duh
  boot.blacklistedKernelModules = [ "nouveau" ];

  networking.networkmanager.enable = true;

  networking.hostName = "booblik";

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    wget
    curl
  ];

  environment.variables.EDITOR = "nvim";

  users.users = {
    nurgler = {
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "kanzascityshuffle";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJS5Hq9Kd+P8H7aXS3Evv7f6XyjE2J9hVTrOQOBK9CQ6xGQ9qbJ7q2hXbNizLgaGU61l9mGbnipPHR5rh5HVJEoyPBqvtraMk5+etM64pxCTos2bOdGbnN0U8HaMFa0hWDnpT3m0q/2GWY82hKK0wxQOyLjx8wTp//KJRClWmZcsNFLXPwXTe08TP5cf7VkiO84HrLoPpjYrytSY0AdBPtskIYBYAvjJGG0Wq99w1jAIDi1+C9TK4AvMJyPQS2ljaQiaJuodbhmViX+HpwdTb1LkHshH0/4xhB7HgniI2uu1/1iuiPbR8GSSKOiF3fz/dHZPb82XmmiBdOqyAPzzAxHxj3ecPtcqnHTAMWe8NB6J9yBcl35/gbAgY0ANUO5tu49hrc2VW6eAjPj8jrUVG94ptKZaIw0jX2Icbk3ko5mrd9J0nphOlZ0re1ZxLVOjgEXci6x9nopgTN0tMzq6iHL6OmONwxS3WPuJsRV2FIdC1hEBwnpCix7XPJWbNbwns= nurgler@zefirka"
      ];
      extraGroups = [
        "wheel"
        "audio"
        "video"
        "networkmanager"
      ];
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
