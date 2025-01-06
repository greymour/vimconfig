require("greymour.set")
require("greymour.remap")
require("greymour.lazy")
local augroup = vim.api.nvim_create_augroup
local GreymourGroup = augroup('greymour', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
  require("plenary.reload").reload_module(name)
end

autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',
      timeout = 40,
    })
  end,
})

-- I forget what this does
autocmd({ "BufWritePre" }, {
  group = GreymourGroup,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- order of colours in tables is 1: bg, 2: fg
local function set_line_nr_colours(current_line, other_lines)
  -- line number colour in a file
  vim.cmd('hi LineNr guibg=' .. current_line[1] .. ' guifg=' .. current_line[2])
  -- this changes the line number colour in netrw
  vim.cmd('hi CursorLineNr guibg=' .. current_line[1] .. ' guifg=' .. current_line[2])
  -- overrides the LineNr setting for lines above and below the current line
  vim.cmd('hi LineNrAbove guibg=' .. other_lines[1] .. ' guifg=' .. other_lines[2])
  vim.cmd('hi LineNrBelow guibg=' .. other_lines[1] .. ' guifg=' .. other_lines[2])
end

local function setup_catppuccin()
  vim.cmd 'colorscheme catppuccin-mocha'
  set_line_nr_colours({ '#7253c6', '#ffffff' }, { 'none', '#bfbfbf' })
end
setup_catppuccin()
