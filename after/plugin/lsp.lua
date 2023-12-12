local lsp = require("lsp-zero")
local lspconfig = require('lspconfig')
local autocmd = vim.api.nvim_create_autocmd

lsp.preset("recommended")

lsp.ensure_installed({
  'tsserver',
  'rust_analyzer',
  'eslint',
  'pyright',
  'gopls',
  'jsonls',
  'bashls',
  'dockerls',
  'cssls',
  'marksman',
  'lua_ls',
  'pylsp',
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()


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

lsp.setup_nvim_cmp({
  cmp.PreselectMode.None,
  mapping = cmp_mappings,
})

-- this doesn't seem to be always working, interesting

lsp.set_preferences({
  suggest_lsp_servers = true,
  sign_icons = {
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
  }
})

lspconfig.pyright.setup({
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "strict",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
        stubPath = vim.fn.stdpath('data') .. '/stubs'
      }
    }
  }
})


autocmd("BufWritePre", {
  pattern = { '*.js', '*.jsx', '*.ts', '*.tsx' },
  callback = function() vim.cmd("EslintFixAll") end
})

autocmd("BufWritePre", {
  pattern = { '*.py' },
  callback = function()
    print('trying to format python')
    --os.execute('python3 -m autopep8 --in-place --aggressive ' .. vim.fn.expand('%:p'))
  end
})

vim.lsp.buf.format {
  filter = function(client)
    return client.name ~= "yamlls" and client.name ~= "marksman"
  end
}

-- IM" CONFIGURING ALL THIS SHIT WRONG
-- I'M USING MASON TO MANAGE THIS SHIT SO NONE OF HTIS IS WORKINGGGGG
-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#configure-language-servers
require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    pyright = lspconfig.pyright.setup {},
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
                --max_line_length = 120,
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
  }
})

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
    --'python'
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
lsp.setup()
--
-- vim.diagnostic.config({
--   virtual_text = true
-- })
