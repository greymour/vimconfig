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
  javascriptreact = "console.log('%s: ', %s);",
  typescriptreact = "console.log('%s: ', %s);",
  typescript = "console.log('%s: ', %s);",
  javascript = "console.log('%s: ', %s);",
  lua = "print('%s: ', %s)",
  go = "fmt.Printf(\"%s: %%v\", %s)",
  rust = "println!(\"%s: {:?}\", %s);",
  python = "print('%s: ', %s)",
}

-- using normal o to open a new line below the current line, and then insert the new text
-- if the log type ends with a semicolon, move the cursor back one character, and then start insert mode
-- which starts inserting text behind the cursor
vim.keymap.set("n", "<leader>ll", function()
  local filetype = vim.bo.filetype
  local log_cmd = log_table[filetype]
  if type(log_cmd) ~= 'string' then
    print("no log for this filetype: ", filetype)
    return
  end
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local symbol = vim.fn.expand('<cword>')
  local new_text = ''
  if symbol:match("[A-Za-z]") then
    new_text = string.format(log_cmd, symbol, symbol)
  else
    new_text = string.format(log_cmd, line_number, '')
  end
  vim.cmd(string.format('normal! o%s', new_text))

  if string.sub(log_cmd, -1) == ';' then
    vim.cmd("normal! h")
  end

  vim.cmd("startinsert")
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
  bash = '#',
  sh = '#',
  zsh = '#',
  dockerfile = '#',
  toml = '#',
  mk = '#',
  makefile = '#',
  make = '#',
  yaml = '#',
}


local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end
-- insert the comment character for the current file type at the start of each line in the range from the start to the
-- end of the visual selection
vim.keymap.set({ 'v', 'n' }, '<leader>/', function()
  local file_type = vim.bo.filetype
  if type(comment_table[file_type]) ~= "string" then
    print("no log for this filetype: ", file_type)
    return
  end
  local comment = comment_table[file_type]
  local comment_len = string.len(comment)
  if comment_len < 1 then
    print("no comment character for this filetype: ", file_type)
    return
  end
  -- vim.fn.getpos() only works for the start and end of the PREVIOUS visual selection, so doing this exits visual mode
  vim.cmd("normal! v")
  -- see :h getpos for what the values here are
  local start_line = vim.fn.getpos("'<")[2]
  local start_col = vim.fn.indent(start_line)
  local end_line = vim.fn.getpos("'>")[2]
  local line_str = vim.fn.getline(start_line)
  -- the start and end of the selection don't care about whether the highlighting is from top to bottom or bottom to top
  -- so we need to move the cursor to the bottom (or top) of the selection to force the direction to be consistent
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  local step_cmd = "j"
  local end_step = "k"
  local adding_comments = string.sub(string.gsub(line_str, "%s+", ""), 1, comment_len) ~= comment
  if adding_comments then
    vim.cmd("normal! ^")
    for cur_line = start_line, end_line do
      if trim(vim.fn.getline(cur_line)) == "" then
        vim.cmd("normal! " .. step_cmd)
      else
        vim.api.nvim_win_set_cursor(0, { cur_line, start_col })
        vim.cmd("normal! i" .. comment .. ' ')
        vim.cmd("stopinsert")
        vim.cmd("normal! " .. step_cmd)
      end
    end
  else
    for cur_line = start_line, end_line do
      if trim(vim.fn.getline(cur_line)):sub(1, comment_len) ~= comment then
        vim.cmd("normal! " .. step_cmd)
      else
        vim.cmd("normal! ^" .. comment_len + 1 .. "x")
        vim.cmd("normal! " .. step_cmd)
      end
    end
  end
  vim.cmd("normal! " .. end_step)
end, {})

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

-- copies the current filename to system clipboard
vim.keymap.set("n", "<leader>cf", "<cmd>let @+ = expand(\"%:t\")<CR>")
-- copies the current file path relative to the project root to the system clipboard
-- eg in ~/.config/nvim/lua/greymour/remap.lua, it would copy lua/greymour/remap.lua
vim.keymap.set("n", "<leader>cp", "<cmd>let @+ = expand(\"%\")<CR>")
