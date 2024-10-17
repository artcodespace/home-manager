{
  config,
  pkgs,
  inputs,
  ...
}: {
  # We could probably do this more simply, but use this from the guide for now
  nixpkgs = {
    overlays = [
      (final: prev: {
        vimPlugins =
          prev.vimPlugins
          // {
            own-colorscheme-pax = prev.vimUtils.buildVimPlugin {
              name = "pax";
              src = inputs.colorscheme-pax;
            };
          };
      })
    ];
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "alunturner";
  home.homeDirectory = "/Users/alunturner";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    # Use this to make the pax scheme appear in the colours list in neovim
    ".config/nvim/colors/pax.lua" = {
      text = "require('pax').load()";
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/alunturner/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Start porting stuff across
  # programs.git = { for ...git
  #   enable = true;
  # };

  programs.lazygit = {
    enable = true;
    settings = {
      gui.border = "double";
      gui.theme.selectedLineBgColor = ["reverse"];
    };
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    # how do I read the toml format of my config into here?
    # see https://github.com/dmmulroy/kickstart.nix/blob/main/module/home-manager.nix
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    envExtra = ''
      eval "$(starship init zsh)"
    '';
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    shell = "${pkgs.zsh}/bin/zsh";
    sensibleOnTop = false;
    terminal = "tmux-256color";
    extraConfig = builtins.readFile ./config/tmux/tmux.conf;
  };

  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    #colorSchemes = {} Perhaps this is used to pull out the custom catpuccin?
    extraConfig = builtins.readFile ./config/wezterm/wezterm.lua;
  };

  programs.neovim = let
    # Helpers to let us load lua config in via the plugin sets
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
  in {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    plugins = [
      {
        plugin = pkgs.vimPlugins.conform-nvim;
        config = toLuaFile ./config/nvim/plugins/conform.lua;
      }
      {
        plugin = pkgs.vimPlugins.fzf-lua;
        config = toLuaFile ./config/nvim/plugins/fzf-lua.lua;
      }
      {
        plugin = pkgs.vimPlugins.nvim-lspconfig;
        config = toLuaFile ./config/nvim/plugins/nvim-lspconfig.lua;
      }
      {
        plugin = pkgs.vimPlugins.nvim-surround;
        config = toLua "require('nvim-surround').setup()";
      }
      {
        plugin = pkgs.vimPlugins.vim-tmux-navigator;
        config = toLua "vim.g.tmux_navigator_no_wrap = 1";
      }
      {
        plugin = pkgs.vimPlugins.own-colorscheme-pax;
        config = toLua "require('pax').load()";
      }
      {
        plugin = pkgs.vimPlugins.nvim-treesitter;
        config = toLuaFile ./config/nvim/plugins/nvim-treesitter.lua;
      }
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
        p.tree-sitter-bash
        p.tree-sitter-comment
        p.tree-sitter-css
        p.tree-sitter-javascript
        p.tree-sitter-json
        p.tree-sitter-lua
        p.tree-sitter-nix
        p.tree-sitter-tsx
        p.tree-sitter-typescript
        p.tree-sitter-vim
        p.tree-sitter-vimdoc
      ]))
    ];
    extraPackages = [
      pkgs.lua-language-server
      pkgs.stylua
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages.eslint
      pkgs.prettierd
      pkgs.nixd
      pkgs.alejandra
      pkgs.vscode-langservers-extracted
    ];
    extraLuaConfig = builtins.readFile ./config/nvim/init.lua;
  };
}
