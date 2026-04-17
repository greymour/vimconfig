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
-- Esc leaves terminal insert mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-N>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
-- triggers formatting
-- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
-- searches for string under cursor (works for variable names, keywords, etc. whatever is under the cursor)
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

vim.keymap.set('n', '<leader>/', 'gcc', { remap = true })
vim.keymap.set('v', '<leader>/', 'gc', { remap = true })

-- table: {
--   error_handler string,
--   number_of_lines to move up after pasting in error handler,
--   [optional] normal command to move to the symbol to the correct column on the current line
-- }
local js_log_table = { 'try {\n _\n} catch (e) {\nconsole.error(\'error: \', e);\n}', 3 }
local error_handler_table = {
  javascriptreact = js_log_table,
  typescriptreact = js_log_table,
  typescript = js_log_table,
  javascript = js_log_table,
  go = { 'if err != nil {\nreturn err\n}', 0 },
  lua = { 'if pcall() then\nelse\nend', 2, 'normal! f(' },
  python = { 'try:\npass\nexcept Exception as e:\npass', 2 },
  rust = { 'match {\nOk(_) => {},\nErr(e) => {}\n}', 3, 'normal! f{h' },
  gleam = { 'match {\nOk(_) => {},\nError(e) => {}\n}', 3, 'normal! f{h' },
}

vim.keymap.set("n", "<leader>tc", function()
  local file_type = vim.bo.filetype
  local error_handler = error_handler_table[file_type]
  if type(error_handler) ~= "table" then
    print("no error handler for this filetype: ", file_type)
    return
  end

  for s in error_handler[1]:gmatch("[^\r\n]+") do
    vim.cmd(string.format('normal! o%s', s))
    vim.cmd("stopinsert")
  end
  vim.cmd(string.format("normal! %ik", error_handler[2]))
  if error_handler[3] then
    vim.cmd(error_handler[3])
  else
    vim.cmd('normal! ^dw')
  end
  vim.cmd("startinsert")
end)

-- @TODO: move all these more complex shortcuts to the shortcuts file I guess

-- @TODO: create a function line_has_content that checks if a line has any text in it, so that then I can use that to
-- decide whether or not to use eg. o to insert a newline or i/a to insert text in the current line
vim.keymap.set("n", "<leader>td", function()
  local cs = vim.bo.commentstring
  if cs == "" then
    print("no commentstring for this filetype: ", vim.bo.filetype)
    return
  end
  vim.cmd("normal! o" .. cs:format("@TODO: "))
  vim.cmd("startinsert!")
end)

vim.keymap.set("n", "<leader>ic", function()
  local cs = vim.bo.commentstring
  if cs == "" then
    print("no commentstring for this filetype: ", vim.bo.filetype)
    return
  end
  vim.cmd("normal! o" .. cs:format(""))
  vim.cmd("startinsert!")
end)

-- copies the current filename to system clipboard
vim.keymap.set("n", "<leader>cf", "<cmd>let @+ = expand(\"%:t\")<CR>")
-- copies the current file path relative to the project root to the system clipboard
-- eg in ~/.config/nvim/lua/greymour/remap.lua, it would copy lua/greymour/remap.lua
vim.keymap.set("n", "<leader>cp", "<cmd>let @+ = expand(\"%:.\")<CR>")

vim.keymap.set("i", "<C-BS>", "<C-w>")

-- I hate having to type :messages constantly when debugging my shit
vim.keymap.set("n", "<leader>mm", "<cmd>:messages<CR>")

vim.keymap.set('i', '<c-space>', function()
  vim.lsp.completion.get()
end)
