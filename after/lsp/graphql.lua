return {
  cmd = { 'graphql-lsp', 'server', '-m', 'stream' },
  filetypes = {
    "javascriptreact",
    "typescriptreact",
    "javascript",
    "typescript",
    "graphql"
  },
  -- Only attach where a GraphQL project config actually exists. Otherwise the
  -- server smears itself across every plain JS/TS buffer.
  root_dir = function(bufnr, on_dir)
    local graphql_configs = {
      '.graphqlrc',
      '.graphqlrc.json',
      '.graphqlrc.yaml',
      '.graphqlrc.yml',
      '.graphqlrc.toml',
      '.graphqlrc.js',
      '.graphqlrc.ts',
      'graphql.config.json',
      'graphql.config.yaml',
      'graphql.config.yml',
      'graphql.config.toml',
      'graphql.config.js',
      'graphql.config.ts',
    }
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local found = vim.fs.find(graphql_configs, { path = fname, upward = true })[1]
    if found then
      on_dir(vim.fs.dirname(found))
    end
  end,
}
