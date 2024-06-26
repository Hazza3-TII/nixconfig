{
  config,
  pkgs,
  lib,
  vars,
  ...
}: {
  # My configuration specific settings
  sifr = {
    graphics.i3.enable = true;
  };

  users.users."${vars.user}" = {
    # Allow passwordless login
    initialHashedPassword = "";
  };
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "${vars.user}";
  };
  # Allow login to root with no password
  users.users.root.initialHashedPassword = "";

  documentation.enable = lib.mkForce false;
  documentation.nixos.enable = lib.mkForce false;
  security.polkit.enable = lib.mkForce false;
  security.rtkit.enable = lib.mkForce false;
  security.apparmor.enable = lib.mkForce false;
}
