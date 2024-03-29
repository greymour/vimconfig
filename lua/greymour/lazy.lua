local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  {
    'nvim-lua/plenary.nvim'
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    'marko-cerovac/material.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.material_style = "palenight"
      vim.cmd 'colorscheme material'
      -- sets all line numbers to white with a blue-purple background, need this to make set the current line number's
      -- colour when editing a file
      vim.cmd ':hi LineNr guibg=#7253c6 guifg=#ffffff'
      -- this changes the line number colour in netrw
      vim.cmd ':hi CursorLineNr guibg=#7253c6 guifg=#ffffff'
      -- overrides the LineNr setting for lines above and below the current line to an off-white
      vim.cmd ':hi LineNrAbove guibg=none guifg=#bfbfbf'
      vim.cmd ':hi LineNrBelow guibg=none guifg=#bfbfbf'
    end
  },
  {
    "hrsh7th/nvim-cmp",
    -- load cmp on InsertEnter
    event = "InsertEnter",
    -- these dependencies will only be loaded when cmp loads
    -- dependencies are always lazy-loaded unless specified otherwise
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
    },
    config = function()
      -- ...
    end,
  },
  {
    "folke/trouble.nvim",
    config = function()
      require("trouble").setup {
        icons = false,
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  },
  -- to get syntax highlighting for styled-components, run TSInstall css
  {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  },
  {
    "ThePrimeagen/harpoon",
    -- branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  { "theprimeagen/refactoring.nvim" },
  -- I never use undotree so commenting out
  --  "mbbill/undotree"
  { "tpope/vim-fugitive" },
  { "nvim-treesitter/nvim-treesitter-context" },
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    dependencies = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lua' },

      -- Snippets
      { 'L3MON4D3/LuaSnip' },
      { 'rafamadriz/friendly-snippets' },
    }
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function() require('gitsigns').setup() end
  },
  { 'windwp/nvim-ts-autotag' },
  {
    'shortcuts/no-neck-pain.nvim',
    config = function()
      require('no-neck-pain').setup({
        width = 150,
        minSideBufferWidth = 10,
        mappings = {
          enabled = true,
          toggle = '<leader>np',
        },
        buffers = {
          scratchPad = {
            -- set to `false` to disable auto-saving
            enabled = true,
            -- set to `nil` to default to current working directory
            location = "~/notes/",
          },
          bo = {
            filetype = "md"
          },
        },
      })
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  {
    'virchau13/tree-sitter-astro',
    dependencies = { 'nvim-treesitter/nvim-treesitter' }
  },
}

-- if this returns '/' then we're on macos, which means it's my work laptop
if package.config:sub(1, 1) == '/' then
  table.insert(plugins, { 'github/copilot.vim' })
end

require("lazy").setup(plugins)
