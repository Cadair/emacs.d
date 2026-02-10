{
  config,
  lib,
  pkgs,
  ...
}: let
  cadairEmacs = config.perSystem.${config.nixpkgs.system}.cadairEmacs;
  # cadairEmacsPkgs = config.perSystem.${config.nixpkgs.system}.cadairEmacsPkgs;
  cfg = config.cadair.emacs;
in {
  options.cadair.emacs = {
    enable = lib.mkEnableOption "Cadair's emacs";
    emacs-package = lib.mkPackageOption pkgs "emacs" { default = cadairEmacs; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fira-code
      nerd-fonts.fira-code
      fira-code-symbols
      git
      ripgrep
      fd
      emacs-all-the-icons-fonts
      # spelling
      ispell
      # nix lsp
      nil
      nixd
      # yaml
      yaml-language-server
      harper
      # mermaid
      mermaid-cli
    ]  ++ [
      # lsp
      pkgs.unstable.python313Packages.python-lsp-server
      pkgs.unstable.python313Packages.ruff
      pkgs.unstable.python313Packages.pylsp-mypy
      pkgs.unstable.ty
      # dap
      pkgs.unstable.python313Packages.debugpy
      # rust
      pkgs.unstable.rust-analyzer
    ] ++ lib.optionals (pkgs.stdenv.isLinux) [
      pkgs.wtype
    ];

    # emacs
    programs.emacs = {
      enable = true;
      package = cfg.emacs-package;
    };

    # consider having init.el built from config.org automatically here
    # with pkgs.runCommand
    home.file.emacs-init = {
      source = ../init.el;
      target = ".emacs.d/init.el";
    };

    # home.file.emacs-local-packages = {
    #   source = ../local-packages;
    #   target = ".emacs.d/local-packages/";
    #   recursive = true;
    # };

    home.file.emacs-snippets = {
      source = ../snippets;
      # Copy these snippets to a different dir so the default is still writeable
      target = ".emacs.d/hm-snippets/";
      recursive = true;
    };

    home.file.emacs-capture = {
      target = ".config/bin/emacs-capture";
      executable = true;
      text = ''
        #!/bin/sh
        # Setup info here: http://www.mediaonfire.com/blog/2017_07_21_org_protocol_firefox.html
        ${cfg.emacs-package.out}/bin/emacsclient -c -F "((name . \"emacs-capture\") (title . \"emacs-capture\") (height . 30) (width . 110))" "$@" &
        '';
    };

    # Add a protocol handler for org-protocol which uses our capture script
    # This can be configured to use with firefox / chrome using this:
    # https://github.com/sprig/org-capture-extension
    xdg.desktopEntries = lib.mkIf pkgs.stdenv.isLinux {
      org-protocol = {
        name = "org-protocol";
        exec = "${config.home.homeDirectory}/.config/bin/emacs-capture %u";
        type= "Application";
        terminal = false;
        categories = [ "System" ];
        mimeType = [ "x-scheme-handler/org-protocol" ];
      };
    };

    # Write a custom emacsd
    systemd.user.services.emacsd = {
      Unit = {
        Description = "Emacs: the extensible, self-documenting text editor";
        After = ["graphical-session.target"];
        Requires = ["gpg-agent.service"];
      };

      Service = {
        Environment = ["SSH_AUTH_SOCK=%t/gnupg/S.gpg-agent.ssh" "PATH=/run/current-system/sw/bin/:${config.home.homeDirectory}/.nix-profile/bin/" ];
        EnvironmentFile = "${config.home.homeDirectory}/${config.home.file.session_env.target}";
        Type = "forking";
        ExecStart = "${config.programs.emacs.finalPackage.out}/bin/emacs --daemon";
        ExecStop = "${config.programs.emacs.finalPackage.out}/bin/emacsclient --eval (kill-emacs)";
        Restart = "always";
      };

      Install = {
        WantedBy = ["graphical-session.target" "sway-session.target"];
      };
    };

    systemd.user.services.emacs-todo = {
      Unit = {
        Description = "Emacs Agenda Window";
        After = ["emacsd.service"];
        Requires = ["emacsd.service"];
      };

      Service = {
        Type = "simple";
        ExecStartPre = "${pkgs.coreutils.out}/bin/sleep 10";
        ExecStart = ''${cfg.emacs-package.out}/bin/emacsclient -c -F "((title . \"emacs-todo\") (name . \"emacs-todo\") (height . 60) (width . 190))" --eval '(org-agenda nil "p")' '';
        Restart = "on-failure";
      };

      Install = {
        WantedBy = ["sway-session.target"];
      };
    };

    home.file.waybar-get-org-task = {
      target = ".config/waybar/get_org_task.sh";
      executable = true;
      text = ''
        #!/bin/sh

        ${config.lib.shell.exportAll config.home.sessionVariables}

        json=$(${cfg.emacs-package.out}/bin/emacsclient --eval '(org-clock-waybar-output-task)' 2> /dev/null)
        status=$?
        [ $status -eq 0 ] && echo $(echo $json | ${pkgs.jq}/bin/jq fromjson --unbuffered --compact-output) || echo ""
    '';
    };
  };
}
