-- set leader to space instead of backslash
vim.g.mapleader = " "
-- change default map for opening netrw to <leader>pv
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
-- Line numbers etc in Netrw
vim.cmd([[let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro']])
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
-- `n` skips to next occurence of symbol under cursor
vim.keymap.set("n", "n", "nzzzv")
-- `N` skips to previous occurence of symbol under cursor
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
-- allows pasting of text above/below current line, and left/right of cursor
-- also pastes without overwriting clipboard
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
-- copies highlighted text to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
-- copies whole line to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Control C exits insert mode
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
-- triggers formatting
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
-- searches for string under cursor (works for variable names, keywords, etc. whatever is under the cursor)
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

local log_table = {
  javascriptreact = { "console.log('%s: ', %s);", 3 },
  typescriptreact = { "console.log('%s: ', %s);", 3 },
  typescript = { "console.log('%s: ', %s);", 3 },
  javascript = { "console.log('%s: ', %s);", 3 },
  lua = { "print('%s: ', %s)", 0 },
  go = { "fmt.Printf(\"%s: %%v\", %s)", 1 },
  rust = { "println!(\"%s: {:?}\", %s);", 2 },
  python = { "print('')", 0 },
}

vim.keymap.set("n", "<leader>ll", function()
  local type = vim.bo.filetype
  if log_table[type] then
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local new_text = string.format(log_table[type][1], line, '')
    vim.cmd(string.format('normal o%s', new_text))
    vim.cmd("startinsert")
  else
    print("no log for this filetype: ", type)
  end
end)

local comment_table = {
  javascriptreact = '//',
  typescriptreact = '//',
  typescript = '//',
  javascript = '//',
  lua = '--',
  go = '//',
  rust = '//',
  python = '#',
}

-- @TODO: make this work for removing comments as well
-- insert the comment character for the current file type at the start of each line in the range from the start to the end of the visual selection
vim.keymap.set('v', '<leader>/', function()
  local type = vim.bo.filetype
  if log_table[type] then
    -- vim.fn.getpos() only works for the start and end of the PREVIOUS visual selection, so doing this exits visual mode
    vim.cmd("normal v")
    local start = vim.fn.getpos("'<")
    local finish = vim.fn.getpos("'>")
    local line = start[2]
    local end_line = finish[2]
    local comment = comment_table[type]
    for i = line, end_line do
      vim.cmd(string.format('%d,%d s/^/%s /', i, i, comment))
    end
  else
    print("no log for this filetype: ", type)
  end
end, {})

-- copies the current filename to system clipboard
vim.keymap.set("n", "<leader>cf", "<cmd>let @+ = expand(\"%:t\")<CR>")

--local builtin = require('telescope.builtin')
--
--vim.keymap.set('n', '<leader>vgr', function()
--  vim.cmd('vimgrep')
--end)
