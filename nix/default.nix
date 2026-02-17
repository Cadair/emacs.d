{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cadair.emacs;
  emacsPackages = (epkgs: with epkgs; [
    alert
    auctex
    blamer
    breadcrumb
    browse-kill-ring
    cape
    consult
    consult-eglot
    corfu
    dape
    dashboard
    diff-hl
    diminish
    doom-modeline
    eat
    eglot
    ement
    evil
    evil-collection
    evil-nerd-commenter
    flymake
    flymake-ruff
    forge
    general
    git-link
    git-timemachine
    hl-todo
    htmlize
    indent-bars
    jinja2-mode
    magit
    marginalia
    mermaid-mode
    micromamba
    mixed-pitch
    nerd-icons
    nerd-icons-completion
    nerd-icons-completion
    nerd-icons-corfu
    nerd-icons-dired
    nerd-icons-ibuffer
    nix-ts-mode
    orderless
    org-modern
    ox-reveal
    project
    python-black
    python-isort
    python-pytest
    pyvenv
    quarto-mode
    rainbow-delimiters
    ranger
    reformatter
    request
    ruff-format
    rustic
    secretaria
    tabspaces
    terraform-mode
    toc-org
    tree-sitter
    tree-sitter-langs
    treesit-fold
    treemacs
    treemacs-evil
    treemacs-magit
    treesit-fold
    treesit-grammars.with-all-grammars
    vertico
    which-key
    yasnippet-snippets
    zeal-at-point
  ]);
in {
  options.cadair.emacs = {
    enable = lib.mkEnableOption "Cadair's emacs";
    emacs-package = lib.mkPackageOption pkgs "emacs30-pgtk" { };
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
      # lsp
      unstable.python313Packages.python-lsp-server
      unstable.python313Packages.ruff
      unstable.python313Packages.pylsp-mypy
      unstable.ty
      # spelling
      ispell
      # nix lsp
      nil
      nixd
      # dap
      unstable.python313Packages.debugpy
      # rust
      unstable.rust-analyzer
      # yaml
      yaml-language-server
      harper
      # mermaid
      mermaid-cli
    ] ++ lib.optionals (pkgs.stdenv.isLinux) [
      wtype
    ];

    # emacs
    programs.emacs = {
      enable = true;
      package = cfg.emacs-package;
      extraPackages = emacsPackages;
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
