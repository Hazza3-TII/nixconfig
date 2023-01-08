{ nixosConfig, config, pkgs, lib, ... }:
{
  config = lib.mkMerge [
    ({
      # Default across all installations
      programs.git = {
        enable = true;
        package = pkgs.gitAndTools.gitFull;
        aliases = { co = "checkout"; };
        signing.key = nixosConfig.hsys.git.sshkey;
        signing.signByDefault = true;
        delta.enable = true;
        userName = "Humaid Alqasimi";
        extraConfig = {
          core.editor = "nvim";
          init.defaultBranch = "master";
          gpg.format = "ssh";
          tag.gpgsign = true;
          user.allowedSignersFile = "~/.ssh/allowed_signers";
          format.signOff = true; # not respected by git?
          commit.verbose = "yes";
          safe.directory = "/mnt/hgfs/*";
          url = {
            #"git@github.com:".insteadOf = "https://github.com/";
            #"git@git.sr.ht:".insteadOf = "https://git.sr.ht/";
            "git@github.com:".insteadOf = "gh:";
            "git@git.sr.ht:".insteadOf = "srht:";
          };
        };
      };
    })
    (lib.mkIf nixosConfig.hsys.workProfile {
      programs.git = {
        userEmail = "humaid.alqassimi+git@tii.ae";
        extraConfig.url."git@github.com:tiiuae/".insteadOf = "tii:";
      };
    })
    (lib.mkIf (!nixosConfig.hsys.workProfile) {
      # Home-profile only
      programs.git.userEmail = "git@huma.id";
      programs.git.extraConfig = {
        sendmail.smtpserver = "smtp.migadu.com";
        sendmail.smtpuser = "git@humaidq.ae";
        sendmail.smtpencryption = "tls";
        sendmail.smtpserverport = "587";
      };
    })
  ];
}
