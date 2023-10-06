vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
-- these two make it so that when highlighting lines, by holding shift + using
-- either K or J, we can move those hightlighted lines up or down accordingly
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- this map makes J move the next line up and appends it to the current line,
-- separated by a space
vim.keymap.set("n", "J", "mzJ`z")
-- ctrl + d & ctrl + u jump by half a page, maintain cursor position
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>");
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

local log_table = {
  javascriptreact = { "console.log('%s: ', %s);", 3 },
  typescriptreact = { "console.log('%s: ', %s);", 3 },
  typescript = { "console.log('%s: ', %s);", 3 },
  javascript = { "console.log('%s: ', %s);", 3 },
  lua = { "print('%s: ', %s)", 3 },
  go = { "fmt.Printf(\"%s: %%v\", %s)", 1 },
  rust = { "println!(\"%s: {:?}\", %s);", 2 },
}

vim.keymap.set("n", "<leader>ll", function()
  local type = vim.bo.filetype
  print(vim.inspect(type))
  if log_table[type] then
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local text = vim.api.nvim_get_current_line()
    local new_text = string.format(log_table[type][1], line, text)
    vim.api.nvim_set_current_line(new_text)
    vim.api.nvim_win_set_cursor(0, { line, #new_text - log_table[type][2] })
    vim.cmd("startinsert")
  else
    print("no log for this filetype: ", type)
  end
end)

--local builtin = require('telescope.builtin')
--
--vim.keymap.set('n', '<leader>vgr', function()
--  vim.cmd('vimgrep')
--end)
