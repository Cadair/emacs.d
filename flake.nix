{
  description = "Cadair's Emacs Config";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ flake-parts, ... }:
    # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake { inherit inputs; } (top@{ config, withSystem, moduleWithSystem, ... }: {
      imports = [
        # Optional: use external flake logic, e.g.
        # inputs.foo.flakeModules.default
      ];
      flake = {
        # Put your original flake attributes here.
        homeModules = import ./nix;
      };
      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem = { pkgs, ... }: {
        config.packages.cadairEmacs = pkgs.emacs-pgtk.pkgs.withPackages (epkgs: with epkgs; [
            tree-sitter
            tree-sitter-langs
            treesit-grammars.with-all-grammars
            nerd-icons-completion
            evil
            evil-collection
            general
            mixed-pitch
            nerd-icons
            nerd-icons-corfu
            nerd-icons-dired
            nerd-icons-ibuffer
            doom-modeline
            breadcrumb
            hl-todo
            flymake
            project
            tabspaces
            eglot
            dape
            yasnippet-snippets
            treesit-fold
            pyvenv
            micromamba
            python-pytest
            flymake-ruff
            python-isort
            ruff-format
            python-black
            reformatter
            nix-ts-mode
            quarto-mode
            rustic
            terraform-mode
            jinja2-mode
            mermaid-mode
            auctex
            magit
            forge
            diff-hl
            git-link
            git-timemachine
            blamer
            corfu
            cape
            orderless
            vertico
            marginalia
            nerd-icons-completion
            consult
            diminish
            rainbow-delimiters
            which-key
            treemacs
            treemacs-evil
            treemacs-magit
            ranger
            dashboard
            browse-kill-ring
            evil-nerd-commenter
            indent-bars
            eat
            zeal-at-point
            toc-org
            # org-tempo
            org-modern
            htmlize
            ox-reveal
            alert
            secretaria
            request
            ement
        ]);
        # config.packages.cadairEmacsPkgs = with pkgs; [ ty ];
      };
    });
}
  # outputs =
  #   inputs@{ self, ... }:
  #   let
  #     supportedSystems = [
  #       "aarch64-linux"
  #       "x86_64-linux"
  #     ];

  #     # Function to generate a set based on supported systems:
  #     forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

  #     # Attribute set of nixpkgs for each system:
  #     nixpkgsFor = forAllSystems (system: import inputs.nixpkgs { inherit system; });
  #     nixpkgsUnstableFor = forAllSystems (system: import inputs.nixpkgs-unstable { inherit system; });

  #     cadairEmacs = forAllSystems (system:
  #       let
  #         pkgs = nixpkgsFor.${system};
  #         emacs = pkgs.emacsPackagesFor pkgs.emacs-pgtk;
  #       in
  #         emacs.emacsWithPackages (epkgs: with epkgs; [
            # tree-sitter
            # ement
          #] )
  #     );

  #     cadairEmacsPkgs = forAllSystems (system:
  #       let
  #         pkgs = nixpkgsFor.${system};
  #         unstablePkgs = nixpkgsUnstableFor.${system};
  #       in
  #         with pkgs; [
            # # rust
            # unstablePkgs.rust-analyzer
          #]# 
  #     );
  #   in
  #     {
  #       devShells = forAllSystems (system:
  #       let
  #         pkgs = nixpkgsFor.${system};
  #       in
  #         {
  #           default = pkgs.mkShell {
  #             buildInputs = [
  #               (cadairEmacsPkgs.${system})
  #               (cadairEmacs.${system})
  #             ];
  #           };
  #         }
  #       );
  #       homeManagerModules.cadair-emacs =
  #         { config, lib, ... }:
  # let
  #   cadairEmacsPkgs = cadairEmacsPkgs.${config.nixpkgs.system};
  # in
  #       {
  #         imports = [
  #           (import ./nix {
  #             inherit (cadairEmacs.${config.nixpkgs.system}) cadairEmacs;
  #             inherit cadairEmacsPkgs;
  #             inherit config;
  #             inherit lib;
  #             inherit (nixpkgsFor.${config.nixpkgs.system}) pkgs;
  #           })
  #         ];
  #       };
  #     };
# }
