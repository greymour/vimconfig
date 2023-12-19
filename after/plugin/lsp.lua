local lsp = require("lsp-zero")
local lspconfig = require('lspconfig')
local autocmd = vim.api.nvim_create_autocmd

lsp.preset("recommended")

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
  ['<CR>'] = cmp.mapping.confirm({ select = true }),
  ['<S-Space>'] = cmp.mapping.abort(),
  ['<C-Space>'] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

cmp.setup({
  -- add these back in if I decide I want bordered windows (need to pass in a few other options as well)
  --  window = {
  --    completion = cmp.config.window.bordered(),
  --    documentation = cmp.config.window.bordered(),
  --  },
  mapping = cmp.mapping.preset.insert({
    ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<S-Space>'] = cmp.mapping.abort(),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  sources = {
    { name = 'nvim_lsp' }
  }
})

lsp.set_preferences({
  suggest_lsp_servers = true,
  sign_icons = {
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
  }
})

-- not using pyright at the moment, testing to see if pylsp is enough
-- lspconfig.pyright.setup({
--   settings = {
--     python = {
--       analysis = {
--         typeCheckingMode = "strict",
--         autoSearchPaths = true,
--         useLibraryCodeForTypes = true,
--         diagnosticMode = "workspace",
--         stubPath = vim.fn.stdpath('data') .. '/stubs'
--       }
--     }
--   }
-- })


autocmd("BufWritePre", {
  pattern = { '*.js', '*.jsx', '*.ts', '*.tsx' },
  callback = function()
    -- this makes it so that if eslint isn't installed in a project, we don't get an error on every save
    if vim.fn.exists(':EslintFixAll') > 0 then
      vim.cmd("EslintFixAll")
    end
  end
})

vim.lsp.buf.format {
  filter = function(client)
    return client.name ~= "yamlls" and client.name ~= "marksman"
  end
}

lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }
  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)


  local supported_types = { 'javascriptreact', 'typescriptreact', 'typescript', 'javascript', 'lua', 'go', 'rust',
    'python', 'kotlin',
  }

  autocmd("BufWritePre", {
    callback = function()
      local type = vim.bo.filetype
      if vim.tbl_contains(supported_types, type) then
        vim.lsp.buf.format()
      end
    end
  })
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    'tsserver',
    'rust_analyzer',
    'eslint',
    -- 'pyright',
    'gopls',
    'jsonls',
    'bashls',
    'dockerls',
    'cssls',
    'marksman',
    'lua_ls',
    'pylsp',
    'kotlin_language_server',
  },
  handlers = {
    lsp.default_setup,
    lua_ls = lspconfig.lua_ls.setup {
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' }
          }
        }
      }
    },
    -- if I want to use pyright, use the commented out setup function above
    --    pyright = lspconfig.pyright.setup {},
    pylsp = function()
      lspconfig.pylsp.setup({
        settings = {
          pylsp = {
            configuration_sources = { "flake8" },
            plugins = {
              pycodestyle = {
                enabled = false,
                -- max_line_length = 120
              },
              mccabe = {
                enabled = false
              },
              pyflakes = {
                enabled = false
              },
              pylint = {
                enabled = false
              },
              flake8 = {
                enabled = true,
                maxLineLength = 120,
                -- ignore = {},
                -- extend_ignore = {}
              },
              autopep8 = {
                enabled = true,
              },
              yapf = {
                enabled = false,
              }
            }
          },
        }
      })
    end,
    bashls = lspconfig.bashls.setup({
      cmd = { "bash-language-server", "start" },
      filetypes = { "sh", "zsh" },
      root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
      settings = {
        bash = {
          filetypes = { "sh", "zsh" }
        }
      }
    }),
    yamlls = lspconfig.yamlls.setup({
      filetypes = { "yaml", "yml" }
    }),
    kotlin_language_server = lspconfig.kotlin_language_server.setup({
      cmd = { "kotlin-language-server" },
      filetypes = { "kotlin" },
    }),
  }
})


vim.diagnostic.config({
  virtual_text = true
})
