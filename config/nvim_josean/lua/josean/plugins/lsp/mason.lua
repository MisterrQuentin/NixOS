-- import mason
local mason = require("mason")

-- import mason-lspconfig
local mason_lspconfig = require("mason-lspconfig")

local mason_tool_installer = require("mason-tool-installer")

-- enable mason and configure icons
mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

mason_lspconfig.setup({
  -- list of servers for mason to install
  ensure_installed = {
    "ts_ls",
    "html",                   -- changed from html-lsp
    "cssls",                  -- changed from css-lsp
    "tailwindcss",           -- changed from tailwindcss-language-server
    "svelte",                -- changed from svelte-language-server
    "lua_ls",
    "graphql",
    "emmet_ls",
    "prismals",  -- This is the correct name for mason-lspconfig
    "pyright",
  },
})

mason_tool_installer.setup({
  ensure_installed = {
    "prettier", -- prettier formatter
    "stylua", -- lua formatter
    "isort", -- python formatter
    "black", -- python formatter
    "pylint",
    "eslint_d",
  },
})
