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
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000
  },
  -- {
  --   "hrsh7th/nvim-cmp",
  --   -- load cmp on InsertEnter
  --   event = "InsertEnter",
  --   -- these dependencies will only be loaded when cmp loads
  --   -- dependencies are always lazy-loaded unless specified otherwise
  --   dependencies = {
  --     "hrsh7th/cmp-nvim-lsp",
  --     "hrsh7th/cmp-buffer",
  --   },
  --   config = function()
  --     -- ...
  --   end,
  -- },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
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
  { 'neovim/nvim-lspconfig' },
  { "nvim-treesitter/nvim-treesitter-context" },
  {
    'williamboman/mason.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    -- dependencies = {
    --   "graphql-language-service-cli", -- required for graphql-lsp
    -- },
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
  -- {
  --   "roobert/tailwindcss-colorizer-cmp.nvim",
  --   -- optionally, override the default options:
  --   config = function()
  --     require("tailwindcss-colorizer-cmp").setup({
  --       color_square_width = 2,
  --     })
  --   end
  -- },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  { 'tpope/vim-dadbod' },
  -- { 'kristijanhusak/vim-dadbod-completion' },
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod' },
      -- { 'kristijanhusak/vim-dadbod-completion', }
    },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 0
      vim.g.dbs = {
        { name = 'treecko', url = 'postgres://treecko@localhost:10000/treecko' },
      }
    end,
  },
  { 'mfussenegger/nvim-lint' },
  -- { 'mfussenegger/nvim-dap' }
  {
    'brexhq/kotlin-bazel.nvim',
    ft = "kotlin",
    opts = {},
  },
  -- { 'olimorris/codecompanion.nvim' },
}

require("lazy").setup(plugins)
