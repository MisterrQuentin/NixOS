require("trouble").setup()

-- set keymaps
local keymap = vim.keymap

keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<CR>", { desc = "Open/close trouble list" })
keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<CR>", { desc = "Open trouble workspace diagnostics" })
keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<CR>", { desc = "Open trouble document diagnostics" })
keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<CR>", { desc = "Open trouble quickfix list" })
keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<CR>", { desc = "Open trouble location list" })
keymap.set("n", "<leader>xt", "<cmd>TodoTrouble<CR>", { desc = "Open todos in trouble" })

