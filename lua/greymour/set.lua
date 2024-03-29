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

-- @TODO: get rid of this shit
-- local HOME = os.getenv("HOME") and os.getenv("HOME") or os.getenv("LOCALAPPDATA")

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

vim.opt.updatetime = 50

vim.opt.colorcolumn = "120"
--vim.opt.iskeyword = "_"
