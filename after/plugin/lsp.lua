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
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()


local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['K'] = cmp.mapping.select_prev_item(cmp_select),
  ['J'] = cmp.mapping.select_next_item(cmp_select),
  ['<S-CR>'] = cmp.mapping.confirm({ select = true }),
  ['<S-Space>'] = cmp.mapping.abort(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil
cmp_mappings['<CR>'] = nil

lsp.setup_nvim_cmp({
  cmp.PreselectMode.None,
  mapping = cmp_mappings
})

-- this doesn't seem to be always working, interesting

lsp.set_preferences({
  suggest_lsp_servers = false,
  sign_icons = {
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
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
end)

lspconfig.pyright.setup({
  settings = {
    python = {
      pythonPath = '/usr/local/bin/python3.11',
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

lspconfig.bashls.setup({
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "zsh" },
  root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
  settings = {
    bash = {
      filetypes = { "sh", "zsh" }
    }
  }
})

lspconfig.yamlls.setup({
  filetypes = { "yaml", "yml" }
})

autocmd("BufWritePre", {
  pattern = { '*.js', '*.jsx', '*.ts', '*.tsx' },
  callback = function() vim.cmd("EslintFixAll") end
})

autocmd("BufWritePre", { callback = function() vim.lsp.buf.format() end })

vim.lsp.buf.format {
  filter = function(client)
    return client.name ~= "yamlls" and client.name ~= "marksman"
  end
}



lsp.setup()

vim.diagnostic.config({
  virtual_text = true
})
