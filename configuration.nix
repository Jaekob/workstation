{ config, pkgs, lib, ... }:

{
  # Import hardware configurations
  imports = [
    ./hardware-configuration.nix
  ];

  ##############################
  # System Settings
  ##############################

  # Bootloader settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking settings
  networking.hostName = "enki";  # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "America/Chicago";

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";

  # Environment variables (Add XDG_DATA_DIRS with mkForce to fix gnome meta-data issue)
  environment.variables = {
    XDG_DATA_DIRS = lib.mkForce "${pkgs.gnome3.gnome-settings-daemon}/share:/usr/share";
  };

  ##############################
  # Hardware Configuration
  ##############################

  # Enable OpenGL support system-wide
  hardware.opengl.enable = true;  # Ensure OpenGL support is enabled

  # NVIDIA Setup
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Sound setup with PipeWire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ##############################
  # Display and Desktop Configuration
  ##############################

  # X11 and GNOME Desktop Environment
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  ##############################
  # User Configuration
  ##############################

  users.users.put-username-here = {
    isNormalUser = true;
    description = "Username Here";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      vscode     # Visual Studio Code as an alternative editor
      obsidian   # Personal note-taking
      wezterm    # Terminal emulator of choice
    ];
  };

  # Enable automatic login for the user
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "put-username-here";

  ##############################
  # Tools and Development Setup
  ##############################

  environment.systemPackages = with pkgs; [
    # System-wide Neovim and plugins
    neovim
    vimPlugins.nvim-lspconfig  # Neovim LSP configuration
    vimPlugins.rust-tools-nvim # Rust tools for Neovim (integrates rust-analyzer)
    vimPlugins.nvim-cmp        # Completion framework for Neovim

    # General development and utility tools
    ripgrep     # Fast search tool (integrates with Neovim and Telescope)
    fd          # Modern alternative to find (integrates with Telescope and FZF)
    btop        # System monitoring tool
    xdg-desktop-portal  # Better GNOME integration
    xdg-utils           # XDG environment utilities

    # OpenGL information tool (glxinfo)
    mesa-demos          # Provides glxinfo and other utilities

    # Rust development tools
    rustup      # Manage Rust toolchains
    cargo-edit  # Cargo extensions for managing dependencies (add, rm, upgrade)
    clippy      # Linter for Rust
    rustfmt     # Rust code formatter
  ];

  # Enable Firefox system-wide
  programs.firefox.enable = true;

  # Enable printing service
  services.printing.enable = true;

  ##############################
  # System-Wide Neovim Configuration
  ##############################

  # System-wide Neovim config using `environment.etc`
  environment.etc."nvim/sys-init.vim".text = ''
    set relativenumber
    set number
  '';

  # Ensure Neovim uses this config system-wide
  environment.variables.NVIM_SYSTEM_INIT = "/etc/nvim/sys-init.vim";

  ##############################
  # Security Settings
  ##############################

  nixpkgs.config.allowUnfree = true;

  ##############################
  # Miscellaneous Configurations
  ##############################

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Set NixOS system state version
  system.stateVersion = "24.05";  # Adjust to your installed version
}
