-- @TODO: figure out if this is the best place for this file - it's not really a plugin
-- @TODO: clean up this code I stole from the internet
local ts_utils = require 'nvim-treesitter.ts_utils'

local function get_current_function_name()
  local prev_function_node = nil
  local prev_function_name = ""

  -- < Retrieve the name of the function the cursor is in.
  local current_node = ts_utils.get_node_at_cursor()

  if not current_node then
    print('no node found')
    return ""
  end

  local func = current_node

  while func do
    -- debug statement, use for checking what node types are getting iterated over
    print('get_current_function_name: ', func:type(), ts_utils.get_node_text(func)[1])
    -- original code just checked for `function_definition` but it seems like there's multiple types of function nodes
    -- in treesitter
    -- 'lexical_declaration' is required for javascript arrow functions assigned to variables
    -- ^ we can actually use the `arrow_function` type for this instead
    -- @TODO: clean this up, make it check a table or something
    -- ^ have a nested table that's like { 'programming language' = { 'node type', 'node type', 'node type' } }
    local type = func:type()
    if type == 'function_definition'
        or type == 'function_declaration'
        or type == 'arrow_function'
        or type == 'method_definition'
        or type == 'class_declaration'
        or type == 'function'
    then
      break
    end

    func = func:parent()
  end

  if not func then
    print('no function found')
    prev_function_node = nil
    prev_function_name = ""
    return ""
  end

  if func == prev_function_node then
    return prev_function_name
  end

  prev_function_node = func

  -- recursion WOOHOO
  local find_name
  find_name = function(node)
    for i = 0, node:named_child_count() - 1, 1 do
      local child = node:named_child(i)
      local type = child:type()

      -- @TODO:
      -- maybe add some extra stuff for gleam since the autoformatter works differently than most langs
      print('node 60: ', type, (ts_utils.get_node_text(child))[1])
      if type == 'identifier' or type == 'operator_name' or type == 'property_identifier' or type == 'variable_declaration' then
        return (ts_utils.get_node_text(child))[1]
      else
        local name = find_name(child)

        if name then
          return name
        end
      end
    end

    return ''
  end

  prev_function_name = find_name(func)
  return prev_function_name
end

local js_log_str = { "console.log('%s: ', %s);", 1 }
local bash_log_str = { "echo '%s: ' $%s", 0 }
local log_table = {
  javascriptreact = js_log_str,
  typescriptreact = js_log_str,
  typescript = js_log_str,
  javascript = js_log_str,
  lua = { "print('%s: ', %s)", 0 },
  go = { "fmt.Printf(\"%s: %%v\", %s)", 0 },
  rust = { "println!(\"%s: {:?}\", %s);", 1 },
  python = { "print('%s: ', %s)", 0 },
  sh = bash_log_str,
  bash = bash_log_str,
  gleam = { "io.debug(#(\"%s: \", %s))", 1 },
  elixir = { "IO.puts(\"%s: \", %s)", 0 },
  zig = { "std.debug.print(\"%s: %s\", .{ %s })", 0 },
}

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- using normal o to open a new line below the current line, and then insert the new text
-- if the log type ends with a semicolon, move the cursor back one character, and then start insert mode
-- which starts inserting text behind the cursor

-- @TODO: clean this up, this is very messy
vim.keymap.set("n", "<leader>ll", function()
  local filetype = vim.bo.filetype
  local log_tbl = log_table[filetype]
  local log_cmd = log_tbl[1]
  if type(log_cmd) ~= 'string' then
    print("no log for this filetype: ", filetype)
    return
  end
  local func_name = get_current_function_name()
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local line_txt = trim(vim.api.nvim_buf_get_lines(0, line_number - 1, line_number + 1, true)[1])
  local line_length = #line_txt
  local check_next_line = line_txt:sub(line_length, line_length) == '='
  if (check_next_line) then
    line_txt = vim.api.nvim_buf_get_lines(0, line_number, line_number + 1, true)[1]
  end
  local is_complex_type = type(line_txt:match('[{[(]')) == 'string'
  local symbol = vim.fn.expand('<cword>')
  -- @TODO: change the <cword> to the word under the cursor, and then check if it's a variable or a function
  local new_text = ''
  if symbol:match("[A-Za-z0-9]") then
    -- if func_name is an empty string or just whitespace we want to strip that from the front of the string for better readability
    new_text = string.format(log_cmd, trim(string.format('%s %s', func_name, symbol)), symbol)
  else
    new_text = string.format(log_cmd, trim(string.format('%s %s', func_name, line_number + 1)), '')
  end
  if is_complex_type then
    local idx = (string.find(line_txt, '[[{(]') or 1) - 1
    if check_next_line then
      vim.cmd("normal! j")
    end
    vim.cmd("normal! 0")
    vim.cmd(string.format("normal! %sl", idx))
    vim.cmd("normal! %")
  end
  vim.cmd(string.format('normal! o%s', new_text))

  if log_tbl[2] ~= 0 then
    vim.cmd(string.format("normal! %sh", log_tbl[2]))
  end

  vim.cmd("startinsert")
end)

local plain_js_log_str = { "console.log();", 1 }
local plain_bash_log_str = { "echo ", 0 }
local plain_log_table = {
  javascriptreact = plain_js_log_str,
  typescriptreact = plain_js_log_str,
  typescript = plain_js_log_str,
  javascript = plain_js_log_str,
  lua = { "print()", 0 },
  go = { "fmt.Printf()", 0 },
  rust = { "println!();", 1 },
  python = { "print()", 0 },
  sh = plain_bash_log_str,
  bash = plain_bash_log_str,
  gleam = { "io.debug(#())", 1 },
  elixir = { "IO.puts()", 0 },
  zig = { "std.debug.print()", 0 },
}

vim.keymap.set("n", "<leader>il", function()
  local filetype = vim.bo.filetype
  local log_tbl = plain_log_table[filetype]
  local log_cmd = log_tbl[1]
  if type(log_cmd) ~= 'string' then
    print("no log for this filetype: ", filetype)
    return
  end
  vim.cmd(string.format('normal! o%s', log_cmd))
  if log_tbl[2] ~= 0 then
    vim.cmd(string.format("normal! %sh", log_tbl[2]))
  end

  vim.cmd("startinsert")
end)
