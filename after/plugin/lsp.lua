local lsp = require("lsp-zero")
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local lspconfig = require('lspconfig')

lsp.preset("recommended")

lsp.ensure_installed({
  'tsserver',
  'rust_analyzer',
  'eslint',
  'pyright',
  'gopls',
  'cssls',
  'jsonls',
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()



lsp.set_preferences({
  suggest_lsp_servers = true,
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

lspconfig.tsserver.setup {}

vim.api.nvim_create_autocmd("BufWritePost", { callback = function() vim.lsp.buf.format() end })
autocmd("BufWritePre", {
  pattern = { '*.js', '*.jsx', '*.ts', '*.tsx' },
  callback = function() vim.cmd("EslintFixAll") end
})

lsp.setup()

vim.diagnostic.config({
  virtual_text = true
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = {
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = false }),
  ["<C-Space>"] = cmp.mapping.complete(),
}

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil
cmp.setup({
  mapping = cmp_mappings,
})
