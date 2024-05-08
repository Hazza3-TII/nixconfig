# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  sifr = {
    graphics.gnome.enable = true;
    profiles.laptop = true;
    development.enable = true;
    tailscale = {
      enable = true;
      ssh = true;
    };
  };
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    vscode
    vim
    tree
    gcc
    python3
    tailscale
    ntfs3g
    starship
  ];
  
  # This is for the ghaf remote build
  programs = {
      ssh = {
        startAgent = true;
        extraConfig = ''
	  host red-team
	       user red-team
	       hostname 100.127.162.28
          host ghaf-net
               user root
               hostname 192.168.1.199
	       proxyjump red-team
          host ghaf-host
               user root
               hostname 192.168.101.2
               proxyjump ghaf-net         
        '';
    };

    starship.enable = true;

  }; 
 
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "hazaa" ];

  systemd.services.vboxnet0.enable = false;
  boot.tmp.cleanOnBoot = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # List services that you want to enable:

  systemd.services.time_read = {
    enable = false;
    description = "Read System Time";
    script = ''/home/hazaa/Desktop/Scripts/ReadTime/time_read.sh'';
    #wantedBy = [ "multi-user.target" ];
  };

}
