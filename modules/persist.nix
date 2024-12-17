{ config, pkgs, ... }:
{
  imports = [
    inputs.preservation.nixosModules.preservation
  ];

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      users."jaykchen" = {
        directories = [
          
          
          # VSCode directories
          ".config/Code"              # For settings.json, keybindings.json, and other configs
          ".config/Code/User"         # User-specific settings
          ".vscode"                   # Workspace settings
          ".local/share/code"         # Extensions and other VSCode data
          ".local/state/code"         # VSCode state data
        ];
      };
    };
  };

  systemd.tmpfiles.settings.preservation = {
    "/home/jaykchen/.config".d = { user = "jaykchen"; group = "users"; mode = "0755"; };
    "/home/jaykchen/.config/Code".d = { user = "jaykchen"; group = "users"; mode = "0755"; };
    "/home/jaykchen/.local/share/code".d = { user = "jaykchen"; group = "users"; mode = "0755"; };
    "/home/jaykchen/.local/state/code".d = { user = "jaykchen"; group = "users"; mode = "0755"; };
  };
}
