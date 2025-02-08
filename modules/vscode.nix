{ config, pkgs, ... }:
{
  # #change# System-wide packages
  environment.systemPackages = with pkgs; [
    vscode.fhs
    nixfmt-rfc-style
    piper
    libratbag
    jetbrains.rust-rover
  ];

  services.vscode-server = {
    enable = true;
    enableFHS = true;
  };

  # #change# System-wide VSCode configuration
  environment.etc."vscode/user/settings.json".text = builtins.toJSON {
    "window.restoreWindows" = "none";
    "window.reopenFolders" = "none";
    "password-store" = "basic";
    "workbench.startupEditor" = "none";
    "welcome.enabled" = false;
    "editor.fontFamily" = "'JetBrains Mono'";
    "editor.fontLigatures" = true;
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nil";
    "nix.serverSettings" = {
      "nil" = {
        "formatting" = {
          "command" = [ "nixfmt" ];
        };
      };
    };
    "[nix]" = {
      "editor.defaultFormatter" = null;
    };
    "editor.codeLens" = false;
    "editor.minimap.enabled" = false;
    "editor.wordWrap" = "wordWrapColumn";
    "editor.wordWrapColumn" = 200;
    "editor.inlayHints.enabled" = "offUnlessPressed";
    "editor.inlayHints.fontSize" = 14;
    "editor.fontWeight" = "normal";
    "editor.lineHeight" = 1.2;
    "editor.smoothScrolling" = true;
    "editor.formatOnSave" = true;
    "editor.parameterHints.enabled" = false;
    "editor.quickSuggestions" = false;
    "files.hotExit" = "off";
    "files.autoSave" = "afterDelay";
    "files.autoSaveDelay" = 5000;
    "files.simpleDialog.enable" = true;
    "window.autoDetectColorScheme" = true;
    "window.systemColorTheme" = "auto";
    "workbench.editor.limit.enabled" = true;
    "workbench.editor.limit.excludeDirty" = true;
    "workbench.editor.limit.value" = 5;
    "workbench.editor.enablePreview" = false;
    "workbench.editor.restoreViewState" = false;
    "workbench.preferredLightColorTheme" = "Solarized Light Chandrian";
    "workbench.preferredDarkColorTheme" = "Solarized Dark Chandrian";
    "workbench.colorTheme" = "Solarized Dark Chandrian";
    "terminal.integrated.fontWeight" = "normal";
    "terminal.integrated.inheritEnv" = false;
    "rust-analyzer.completion.privateEditable.enable" = true;
    "rust-analyzer.inlayHints.lifetimeElisionHints.enable" = "never";
    "rust-analyzer.check.features" = "all";
    "rust-analyzer.procMacro.enable" = true;
    "terminal.integrated.rendererType" = "dom";
    "terminal.integrated.shell.linux" = "${pkgs.zsh}/bin/zsh";
    "terminal.integrated.sendKeybindingsToShell" = true;
    "telemetry.telemetryLevel" = "off";
    "remote.SSH.showLoginTerminal" = true;
    "remote.SSH.useLocalServer" = false;
    "remote.SSH.configFile" = "~/.ssh/config";
    "remote.SSH.defaultExtensions" = [
      "ms-vscode.remote-ssh"
    ];
    "remote.SSH.remotePlatform" = {
      "b550" = "linux";
      "md16" = "linux";
      "nr200" = "linux";
      "cloud" = "linux";
    };
  };

  # #change# System-wide VSCode keybindings
  environment.etc."vscode/user/keybindings.json".text = builtins.toJSON [
    {
      key = "ctrl+w";
      command = "editor.action.smartSelect.expand";
      when = "editorTextFocus && editorHasSelection";
    }
    {
      key = "ctrl+w";
      command = "workbench.action.closeActiveEditor";
      when = "editorIsOpen && !editorHasSelection";
    }
    {
      key = "ctrl+w";
      command = "-workbench.action.closeWindow";
      when = "!editorIsOpen";
    }
    {
      key = "ctrl+d";
      command = "editor.action.duplicateSelection";
      when = "editorTextFocus && editorHasSelection";
    }
    {
      key = "ctrl+shift+k";
      command = "editor.action.deleteLines";
      when = "!editorReadonly";
    }
    {
      key = "ctrl+meta+l";
      command = "editor.action.formatDocument.multiple";
    }
    {
      key = "ctrl+shift+a";
      command = "workbench.action.showCommands";
    }
    {
      key = "shift+escape";
      command = "openInIntegratedTerminal";
    }
    {
      key = "alt+left";
      command = "cursorWordStartLeftSelect";
      when = "editorTextFocus";
    }
    {
      key = "alt+right";
      command = "cursorWordEndRightSelect";
      when = "editorTextFocus";
    }
  ];

  # #change# Ensure VSCode config directory exists
  system.activationScripts.vscodeDirs = ''
    mkdir -p /home/jaykchen/.config/Code/User
    ln -sf /etc/vscode/user/settings.json /home/jaykchen/.config/Code/User/settings.json
    ln -sf /etc/vscode/user/keybindings.json /home/jaykchen/.config/Code/User/keybindings.json
    chown -R jaykchen:users /home/jaykchen/.config/Code
  '';
}
