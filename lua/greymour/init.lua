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

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/implementation') then
      -- assign all the keymap stuff for the lsp buffer
      local opts = { buffer = args.buf, remap = false }
      vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
      vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
      vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
      vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
      vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
      vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
      vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
      vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
      vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
      vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    end

    -- Enables nvim's native auto-completion, not using cmp like I used to
    if client:supports_method('textDocument/completion') then
      -- make it so that auto-selection doesn't happen
      vim.cmd [[set completeopt+=menuone,noselect,popup]]
      -- remap it so that it uses Enter to select something instead of ctrl+Y
      vim.cmd [[inoremap <expr> <cr> pumvisible() ? '<c-y>' : '<cr>']]
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, {
        autotrigger = true,
        -- do I really know what this does? no!
        -- convert = function(item)
        --   return { abbr = item.label:gsub('%b()', '') }
        -- end,
      })
    end

    -- Auto-format ("lint") on save.
    -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
    if not client:supports_method('textDocument/willSaveWaitUntil')
        and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
    -- vim.env.ESLINT_D_PPID = vim.fn.getpid()
    -- local js_linters = { 'eslint_d', 'biomejs' }
    -- require('lint').linters_by_ft = {
    --   javascript = js_linters,
    --   typescript = js_linters,
    --   javascriptreact = js_linters,
    --   typescriptreact = js_linters,
    -- }
  end,
})
-- enable LSPs
vim.lsp.enable({
  'lua',
  'ts_ls',
  'graphql',
  'biome',
  'eslint',
  'gleam',
  -- 'kotlin',
})

vim.diagnostic.config {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚",
      [vim.diagnostic.severity.WARN] = "󰀪",
      [vim.diagnostic.severity.HINT] = "󰌶",
      [vim.diagnostic.severity.INFO] = "",
    }
  },
  virtual_text = {
    current_line = false
  }
}
