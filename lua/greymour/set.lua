vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufEnter", {
  pattern = { "*.md", "*.txt" },
  command = "setlocal wrap linebreak"
})

vim.opt.swapfile = false
vim.opt.backup = false
-- vim.opt.undodir = HOME .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 200 -- Optimized for large TS projects (was 50ms)

vim.opt.colorcolumn = "120"
--vim.opt.iskeyword = "_"
-- case-insensitive search unless there's a capital letter in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
