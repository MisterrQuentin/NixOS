-- import nvim-treesitter plugin
local treesitter = require("nvim-treesitter.configs")

-- configure treesitter
treesitter.setup({ 
  -- enable syntax highlighting
  highlight = {
    enable = true,
  },
  -- enable indentation
  indent = { enable = true },
  -- enable autotagging (w/ nvim-ts-autotag plugin)
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
-- Set parser_install_dir to nil to use the system-wide installation
vim.opt.runtimepath:append("/nix/store/*/nvim-treesitter")
require("nvim-treesitter.install").prefer_git = false
