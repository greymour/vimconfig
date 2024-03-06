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
-- @NOTE re: styled components:
-- To get autocompletion/LSP support in styled-components, follow the Visual Studio instructions
-- here: https://github.com/styled-components/typescript-styled-plugin?tab=readme-ov-file#with-visual-studio
-- and then run `TSInstall css` in the nvim command line to get syntax highlighting
--
-- I might be able to get this working w/o needing to install the plugin into the project and instead use a global
-- config, but I haven't been able to get that to work yet, and it's not worth the time

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
    'sqlls',
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
    -- pylsp with mypy seems to be working fine after restarting the terminal, so will continue using that
    -- setup; if I get the freeze on save issue again, will try switching back
    -- pylsp with mypy seems to struggle a bit on really large files
    -- (eg. payments/models.py in PlushCare API is 1700 LOC), so might be worth switching back to see
    -- the difference
    -- if I want to use pyright, use the commented out setup function below
    --    pyright = lspconfig.pyright.setup {
    --      settings = {
    --        python = {
    --          analysis = {
    --            typeCheckingMode = "strict",
    --            autoSearchPaths = true,
    --            useLibraryCodeForTypes = true,
    --            diagnosticMode = "workspace",
    --            stubPath = vim.fn.stdpath('data') .. '/stubs'
    --          }
    --        }
    --      }
    --    },
    --  On my work computer, pylsp gets installed into ~/.local/share/nvim/mason/packages/python-lsp-server.
    --  To install type stubs and pylsp plugins I need to activate the venv in that folder, and then install
    --  them manually using pip in isolated mode, as otherwise I get AWS code artifact 401 errors.
    --  I'm too lazy to figure out an actual fix for this.
    --  To install plugins, go into the pylsp install directory, activate the venv, and do
    --  `pip --isolated install <plugin>`, e.g. `pip --isolated install pylsp-mypy`
    --  Have to install mypy to get type checking with pylsp, instead of needing something like pyright.
    pylsp = function()
      lspconfig.pylsp.setup({
        settings = {
          pylsp = {
            configurationSources = { "flake8" },
            plugins = {
              pycodestyle = {
                enabled = false,
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
                --maxLineLength = 120,
              },
              autopep8 = {
                enabled = true,
              },
              yapf = {
                enabled = false,
              },
              isort = {
                enabled = false,
              },
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
