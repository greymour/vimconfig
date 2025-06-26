---@type vim.lsp.Config
return {
  init_options = { hostInfo = 'neovim' },
  cmd = { 'typescript-language-server', '--stdio' },
  root_markers = { "tsconfig.json" },
  single_file_support = false,
  settings = {
    typescript = {
      tsserver = {
        maxTsServerMemory = 32000,
        nodePath = "node",
      }
    }
  },
}
