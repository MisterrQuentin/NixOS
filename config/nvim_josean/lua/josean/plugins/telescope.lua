local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
	defaults = {
		path_display = { "smart" },
		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_previous, -- move to prev result
				["<C-j>"] = actions.move_selection_next, -- move to next result
				["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
				["<C-q>"] = function(prompt_bufnr)
					actions.send_to_qflist(prompt_bufnr)
					require("trouble").toggle("quickfix")
				end,
				["<C-t>"] = require("trouble.sources.telescope").open,
			},
			n = {
				["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
				["<C-q>"] = function(prompt_bufnr)
					actions.send_to_qflist(prompt_bufnr)
					require("trouble").toggle("quickfix")
				end,
			},
		},
	},
})

telescope.load_extension("fzf")

-- set keymaps
local keymap = vim.keymap -- for conciseness

keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find recent files" })
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
