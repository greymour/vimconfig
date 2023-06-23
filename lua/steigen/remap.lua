
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

-- makes search terms snap to the middle of the screen
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- pastes current register over highlighted selection, does not clear current register
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]]) -- copy register to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]]) -- copy register to system clipboard only within Vim

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>") -- makes ctrl c do the same thing as Esc in vertical edit mode
-- capital Q is bad, it puts us into command mode, which really isn't useful
vim.keymap.set("n", "Q", "<nop>")
-- this lets us use tmux to hop between projects in one session
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- quick fix list stuff
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
-- this lets us highlight and replace all instances of a word in a file
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- lets us chmod + x from within vim
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>");
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)
