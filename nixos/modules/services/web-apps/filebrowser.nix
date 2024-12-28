{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.filebrowser;
  fmt = pkgs.formats.json {};
in {
  options = {
    services.filebrowser = {
      enable = lib.mkEnableOption "FileBrowser";

      package = lib.mkPackageOption pkgs "filebrowser" {};

      user = lib.mkOption {
        default = "filebrowser";
        description = "User for FileBrowser";
        type = lib.types.str;
      };

      group = lib.mkOption {
        default = "filebrowser";
        description = "Group for FileBrowser";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Whether to automatically open the ports for FileBrowser in the firewall";
        type = lib.types.bool;
      };

      settings = lib.mkOption {
        default = {};
        description = "application specific settings";
        type = lib.types.submodule {
          options = {
            address = lib.mkOption {
              default = "0.0.0.0";
              description = "address to listen on";
              type = lib.types.str;
            };

            port = lib.mkOption {
              default = 5983;
              description = "port to listen on";
              type = lib.types.port;
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.filebrowser = {
      after = ["network.target"];
      description = "FileBrowser";
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        # WorkingDirectory = "/var/lib/filebrowser";
        StateDirectory = "filebrowser";
      };

      script = ''
        exec ${lib.getExe cfg.package} --config ${fmt.generate "config.json" cfg.settings}
      '';
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.settings.port];

    users = {
      groups.${cfg.group} = {};
      users.${cfg.user} = {
        group = cfg.group;
        # home = "/var/lib/filebrowser";
        isSystemUser = true;
      };
    };
  };
}
