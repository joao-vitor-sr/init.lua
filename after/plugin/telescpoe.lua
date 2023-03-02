vim.keymap.set('n', '<leader>pf', "<cmd>Telescope find_files<CR>", {})
vim.keymap.set('n', '<C-p>', "<cmd>Telescope git_files<CR>", {})
vim.keymap.set('n', '<leader>ps', function()
  require('telescope.builtin').grep_string({ search = vim.fn.input("Grep > ") });
end)
