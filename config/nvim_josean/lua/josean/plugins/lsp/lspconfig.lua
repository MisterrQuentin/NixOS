-- import required plugins
local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
require("neodev").setup({})

-- Create base capabilities that will be used by all LSP servers
local base_capabilities = vim.lsp.protocol.make_client_capabilities()
base_capabilities = cmp_nvim_lsp.default_capabilities(base_capabilities)
base_capabilities.textDocument.semanticTokens = nil

-- Create the capabilities function
local function create_capabilities()
	local caps = vim.deepcopy(base_capabilities)
	return caps
end

local keymap = vim.keymap -- for conciseness

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf, silent = true }

		-- set keybinds
		opts.desc = "Show LSP references"
		keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

		opts.desc = "Go to declaration"
		keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

		opts.desc = "Show LSP definitions"
		keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

		opts.desc = "Show LSP implementations"
		keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

		opts.desc = "Show LSP type definitions"
		keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

		opts.desc = "See available code actions"
		keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

		opts.desc = "Smart rename"
		keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

		opts.desc = "Show buffer diagnostics"
		keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

		opts.desc = "Show line diagnostics"
		keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

		opts.desc = "Go to previous diagnostic"
		keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

		opts.desc = "Go to next diagnostic"
		keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

		opts.desc = "Show documentation for what is under cursor"
		keymap.set("n", "K", vim.lsp.buf.hover, opts)

		opts.desc = "Restart LSP"
		keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
	end,
})

-- Change the Diagnostic symbols in the sign column (gutter)
local signs = {
	{ name = "DiagnosticSignError", text = " " },
	{ name = "DiagnosticSignWarn", text = " " },
	{ name = "DiagnosticSignHint", text = "󰠠 " },
	{ name = "DiagnosticSignInfo", text = " " },
}

for _, sign in ipairs(signs) do
	vim.fn.sign_define(sign.name, {
		texthl = sign.name,
		text = sign.text,
		numhl = "",
	})
end

-- Setup nixd
require("lspconfig").nixd.setup({
    capabilities = (function()
        local capabilities = create_capabilities()
        capabilities.textDocument.semanticTokens = nil
        capabilities.textDocument.semanticTokensProvider = nil
        return capabilities
    end)(),
    on_init = function(client)
        client.server_capabilities.semanticTokensProvider = nil
    end,
    cmd = { "nixd" },
    settings = {
        nixd = {
            nixpkgs = {
                expr = "import <nixpkgs> { }",
                expr2 = string.format('import (builtins.getFlake "/home/%s/zaneyos").inputs.nixpkgs { }', vim.g.username)
            },
            formatting = {
                command = { "alejandra" },
            },
            options = {
                nixos = {
                    expr = string.format('(builtins.getFlake "/home/%s/zaneyos").nixosConfigurations.%s.options', vim.g.username, vim.g.host),
                },
                home_manager = {
                    expr = string.format('(builtins.getFlake "/home/%s/zaneyos").homeConfigurations.%s.options', vim.g.username, vim.g.username),
                },
            },
        },
    },
    filetypes = { "nix" },
    on_attach = function(client, _)
        client.server_capabilities.semanticTokensProvider = nil
        client.server_capabilities.documentFormattingProvider = true
    end,
})

-- Setup svelte
require("lspconfig").svelte.setup({
    capabilities = create_capabilities(),
    on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = { "*.js", "*.ts" },
            callback = function(ctx)
                client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
            end,
        })
    end,
})

-- Setup graphql
require("lspconfig").graphql.setup({
    capabilities = create_capabilities(),
    filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
})

-- Setup emmet_ls
require("lspconfig").emmet_ls.setup({
    capabilities = create_capabilities(),
    filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
})

-- Setup lua_ls
require("lspconfig").lua_ls.setup({
    capabilities = create_capabilities(),
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            completion = {
                callSnippet = "Replace",
            },
        },
    },
})
