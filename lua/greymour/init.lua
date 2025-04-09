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

local function setup_material()
  vim.g.material_style = "palenight"
  vim.cmd 'colorscheme material'
  -- sets all line numbers to white with a blue-purple background, need this to make set the current line number's
  -- colour when editing a file
  vim.cmd ':hi LineNr guibg=#7253c6 guifg=#ffffff'
  -- this changes the line number colour in netrw
  vim.cmd ':hi CursorLineNr guibg=#7253c6 guifg=#ffffff'
  -- overrides the LineNr setting for lines above and below the current line to an off-white
  vim.cmd ':hi LineNrAbove guibg=none guifg=#8c8c8c'
  vim.cmd ':hi LineNrBelow guibg=none guifg=#8c8c8c'
end

local function setup_catppuccin()
  vim.cmd.colorscheme "catppuccin-mocha"
end

local function my_theme()
  -- baseline bg clour
  vim.o.background = "light"
  vim.cmd('hi Normal guibg=#d7d7d7')

  -- git diff highlights
  vim.cmd ':hi DiffAdd guifg=NvimDarkGrey1 guibg=#15d565'

  -- Identifier     xxx guifg=#a6accd
  -- Data types
  vim.cmd ':hi String guifg=#308d20'
  vim.cmd ':hi Type guifg=#7253c6'
  -- Indifiers
  vim.cmd ':hi Function guifg=#6485ee'
  -- vim.cmd ':hi Macro ctermfg=6 guifg=#6485ee'
  vim.cmd ':hi Special guifg=#6485ee'
  vim.cmd ':hi Statement guifg=#6485ee'
  vim.cmd ':hi @constant.macro guifg=#6485ee'

  vim.cmd ':hi Identifier guifg=#737cb0'
  -- operator and delimiter???
  -- good dark gold colour: #cea009
  vim.cmd ':hi Constant guifg=#cea009'
  vim.cmd ':hi Number guifg=#df5f34'
  vim.cmd ':hi Character guifg=#df5f34'
  vim.cmd ':hi Boolean guifg=#df5f34'

  -- possible things vec! could be:
  -- @constant.macro <- this one!
  -- @lsp.type.macro -> @constant
  -- @lsp.type.enumMember -> @constant
end

-- my_theme()
setup_catppuccin()
