vim.keymap.set("i", "<C-s>", function()
  return vim.fn["codeium#Accept"]()
end, { expr = true })

vim.keymap.set("i", "<M-]>", function()
  return vim.fn["codeium#CycleCompletions"](1)
end, { expr = true })

vim.keymap.set("i", "<M-[>", function()
  return vim.fn["codeium#CycleCompletions"](-1)
end, { expr = true })

vim.keymap.set("i", "<C-]>", function()
  return vim.fn["codeium#Clear"]()
end, { expr = true })

