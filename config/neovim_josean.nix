{
  pkgs,
  username,
  host,
  inputs,
  ...
}: let
  finecmdline = pkgs.vimUtils.buildVimPlugin {
    name = "fine-cmdline";
    src = inputs.fine-cmdline;
  };
  vim-maximizer = pkgs.vimUtils.buildVimPlugin {
    name = "vim-maximizer";
    src = inputs.vim-maximizer;
  };
in {
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      withPython3 = true;
      extraPackages = with pkgs; [
        # LSP
        nixd
        bash-language-server
        shellcheck
        lua-language-server
        gopls
        pyright
        yaml-language-server
        emmet-ls # Add this line
        marksman
        alejandra
        stylua
        # Core tools
        xclip
        wl-clipboard
        ripgrep
        # Python
        nodePackages.prettier
        black
        isort
        pylint
      ];

      plugins = with pkgs.vimPlugins; [
        # Core
        plenary-nvim
        nui-nvim
        lazy-nvim
        nvim-web-devicons
        finecmdline

        # File management
        nvim-tree-lua

        # LSP & Completion
        nvim-lspconfig
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp_luasnip

        # Snippets
        luasnip
        friendly-snippets

        # UI
        lualine-nvim
        bufferline-nvim
        indent-blankline-nvim
        dressing-nvim
        lspkind-nvim

        # Git
        gitsigns-nvim
        lazygit-nvim

        # Treesitter
        nvim-treesitter.withAllGrammars
        nvim-treesitter-textobjects
        nvim-ts-context-commentstring
        nvim-ts-autotag

        # Telescope
        telescope-nvim
        telescope-fzf-native-nvim

        # Navigation
        vim-tmux-navigator
        vim-maximizer

        # Session
        auto-session

        # Editing
        comment-nvim
        nvim-autopairs
        nvim-surround
        substitute-nvim

        # Code Tools
        trouble-nvim
        todo-comments-nvim
        nvim-lint
        conform-nvim

        # Misc
        vim-lastplace
        alpha-nvim
        neodev-nvim
        which-key-nvim
        codeium-vim
        tokyonight-nvim
      ];

      extraConfig = ''
        set noemoji
        set termguicolors
        nnoremap : <cmd>FineCmdline<CR>
      '';

      extraLuaConfig = ''
        vim.g.username = "${username}"
        vim.g.host = "${host}"
        vim.cmd[[colorscheme tokyonight]]

        require("nvim-treesitter.configs").setup({
          highlight = {
            enable = true,
          },
          indent = {
            enable = true
          },
          autotag = {
            enable = true,
          },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "<C-]>",
              node_incremental = "<C-]>",
              scope_incremental = false,
              node_decremental = "<bs>",
            },
          },
        })

        require("nvim-treesitter.install").prefer_git = false

        ${builtins.readFile ./nvim_josean/lua/josean/core/options.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/core/keymaps.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/alpha.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/auto-session.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/autopairs.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/bufferline.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/codeium.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/colorscheme.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/comment.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/dressing.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/formatting.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/gitsigns.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/linting.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/lualine.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/nvim-cmp.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/nvim-tree.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/nvim-treesitter-text-objects.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/substitute.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/surround.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/telescope.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/todo-comments.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/trouble.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/vim-lastplace.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/vim-maximizer.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/which-key.lua}
        ${builtins.readFile ./nvim_josean/lua/josean/plugins/lsp/lspconfig.lua}
        ${builtins.readFile ./nvim/plugins/fine-cmdline.lua}
      '';
    };
  };

  home.file = {
    ".config/nvim/.backup/.keep".text = "";
    ".config/nvim/.swp/.keep".text = "";
    ".config/nvim/.undo/.keep".text = "";
  };
}
