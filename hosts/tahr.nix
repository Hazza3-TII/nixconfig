{
  lib,
  config,
  pkgs,
  vars,
  ...
}: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Annoying Nvidia configurations
  services.xserver.videoDrivers = lib.mkForce ["nvidia"];
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    driSupport = true;
    extraPackages = with pkgs; [vaapiVdpau];
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    #nvidiaPersistenced = true;
    nvidiaSettings = true;
    prime = {
      #offload.enable = true;
      sync.enable = true;
      intelBusId = lib.mkDefault "PCI:0:2:0";
      nvidiaBusId = lib.mkDefault "PCI:1:0:0";
    };
  };

  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.lidSwitch = "ignore";

  # My configuration specific settings
  sifr = {
    graphics = {
      i3.enable = false;
      gnome.enable = true;
    };

    profiles.basePlus = true;
    development.enable = true;
    security.yubikey = true;

    tailscale = {
      enable = true;
      exitNode = true;
      ssh = true;

      # temp
      auth = true;
      tsKey = "tskey-auth-kvPeH22CNTRL-xiNd1gFaJf56jwfxa6BVX5wKjEZXmtrL";
    };
  };

  home-manager.users."${vars.user}" = {
    programs.ssh.matchBlocks = {
      "ghafa" = {
        user = "root";
        hostname = "192.168.101.2";
        proxyJump = "ghafajump";
        checkHostIP = false;
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };
      "ghafajump" = {
        hostname = "192.168.1.35";
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
        user = "ghaf";
        checkHostIP = false;
      };
    };
  };
  programs.ssh.knownHosts = {
    "builder.vedenemo.dev".publicKey = "builder.vedenemo.dev ssh-ed25519 AAAAC3NzaC1    lZDI1NTE5AAAAIHSI8s/wefXiD2h3I3mIRdK+d9yDGMn0qS5fpKDnSGqj";
  };
}
