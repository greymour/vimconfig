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
    if func:type() == 'function_definition'
        or func:type() == 'function_declaration'
        or func:type() == 'arrow_function'
        or func:type() == 'method_definition'
        or func:type() == 'class_declaration'
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

      print('node 60: ', type)
      if type == 'identifier' or type == 'operator_name' or type == 'property_identifier' then
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

local js_log_str = "console.log('%s: ', %s);"
local bash_log_str = "echo '%s: ' $%s"
local log_table = {
  javascriptreact = js_log_str,
  typescriptreact = js_log_str,
  typescript = js_log_str,
  javascript = js_log_str,
  lua = "print('%s: ', %s)",
  go = "fmt.Printf(\"%s: %%v\", %s)",
  rust = "println!(\"%s: {:?}\", %s);",
  python = "print('%s: ', %s)",
  sh = bash_log_str,
  bash = bash_log_str,
  gleam = "io.print(\"%s: \", %s)",
  elixir = "IO.puts(\"%s: \", %s)",
  zig = "std.debug.print(\"%s: %s\", .{ %s })",
}

-- using normal o to open a new line below the current line, and then insert the new text
-- if the log type ends with a semicolon, move the cursor back one character, and then start insert mode
-- which starts inserting text behind the cursor
-- @TODO: add check for if we're in some kind of object/data structure, and if so, insert the log statement
-- at the end of the object/data structure
vim.keymap.set("n", "<leader>ll", function()
  local filetype = vim.bo.filetype
  local log_cmd = log_table[filetype]
  if type(log_cmd) ~= 'string' then
    print("no log for this filetype: ", filetype)
    return
  end
  local func_name = get_current_function_name()
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local symbol = vim.fn.expand('<cword>')
  -- @TODO: change the <cword> to the word under the cursor, and then check if it's a variable or a function
  local new_text = ''
  if symbol:match("[A-Za-z]") then
    new_text = string.format(log_cmd, string.format('%s %s', func_name, symbol), symbol)
  else
    new_text = string.format(log_cmd, string.format('%s %s', func_name, line_number + 1), '')
  end
  vim.cmd(string.format('normal! o%s', new_text))

  if string.sub(log_cmd, -1) == ';' then
    vim.cmd("normal! h")
  end

  vim.cmd("startinsert")
end)

local plain_js_log_str = "console.log();"
local plain_bash_log_str = "echo "
local plain_log_table = {
  javascriptreact = plain_js_log_str,
  typescriptreact = plain_js_log_str,
  typescript = plain_js_log_str,
  javascript = plain_js_log_str,
  lua = "print()",
  go = "fmt.Printf()",
  rust = "println!();",
  python = "print()",
  sh = plain_bash_log_str,
  bash = plain_bash_log_str,
  gleam = "io.print()",
  elixir = "IO.puts()",
  zig = "std.debug.print()",
}

vim.keymap.set("n", "<leader>il", function()
  local filetype = vim.bo.filetype
  local log_cmd = plain_log_table[filetype]
  if type(log_cmd) ~= 'string' then
    print("no log for this filetype: ", filetype)
    return
  end
  vim.cmd(string.format('normal! o%s', log_cmd))
  if string.sub(log_cmd, -1) == ';' then
    vim.cmd("normal! h")
  end

  vim.cmd("startinsert")
end)
