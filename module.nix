{ config
, lib
, pkgs
, ...
}:

with lib;

let
  cfg = config.services.github-actions-runners;
in
{
  imports = [ ./options.nix ];

  config = {
    systemd.services = flip mapAttrs' config.services.github-actions-runners (name: cfg:
      let
        svcName = "github-actions-runner-${name}";
        systemdDir = "github-actions-runners/${name}";
      in
      nameValuePair svcName {
        description = "github-actions-runner service template";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network.target" "network-online.target" ];

        environment = {
          # lmao I think github-runner writes to HOME/.runner FUCKING CHRIST
          HOME = "/var/lib/github-actions-runners/${name}";
        };

        path = (with pkgs; [
          bash
          coreutils
          git
          gnutar
          gzip
        ]) ++ [
          config.nix.package
        ] ++ cfg.extraPackages;

        serviceConfig = {
          RuntimeDirectory = [ "github-actions-runners/${name}" ];
          WorkingDirectory = "/var/lib/github-actions-runners/${name}";
          LogsDirectory = [ "github-actions-runners/${name}" ];
          StateDirectory = [ "github-actions-runners/${name}" ];
          
          ExecStart = "${pkgs.github-runner}/bin/Runner.Listener run --startuptype service";
          ExecStartPre = (pkgs.writeShellScript "pre" ''
            set -x
            set -euo pipefail
            
            mkdir -p "$STATE_DIRECTORY/work"

            token="$(<${escapeShellArg cfg.tokenFile})"

            args=(
              --unattended
              --disableupdate
              --work "$STATE_DIRECTORY/work"
              --url ${escapeShellArg cfg.url}
              --labels ${escapeShellArg (concatStringsSep "," cfg.extraLabels)}
              --pat "$token"
              ${optionalString (name != null ) "--name ${escapeShellArg name}"}
              ${optionalString cfg.replace "--replace"}
              ${optionalString (cfg.runnerGroup != null) "--runnergroup ${escapeShellArg cfg.runnerGroup}"}
              ${optionalString cfg.ephemeral "--ephemeral"}
              ${optionalString cfg.noDefaultLabels "--no-default-labels"}
            )

            # clear runner state, except its work dir
            find "$STATE_DIRECTORY/" -mindepth 1 -not -path "$STATE_DIRECTORY/work" -delete
            
            ${cfg.package}/bin/Runner.Listener configure "''${args[@]}"
          '');

          Restart = "always";

          KillSignal = "SIGINT";
        };
      }
    );
  };
}
