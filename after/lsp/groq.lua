return {
  cmd = { '/Users/kurt/code/groq-language-server/bin/groq-language-server.cjs', '--stdio' },
  filetypes = { 'groq', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  -- Only attach inside an actual Sanity project. Without this guard the server
  -- latches onto every JS/TS buffer (package.json is everywhere) and crashes.
  root_dir = function(bufnr, on_dir)
    local sanity_configs = {
      'sanity.config.ts',
      'sanity.config.js',
      'sanity.config.tsx',
      'sanity.cli.ts',
      'sanity.cli.js',
    }
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local found = vim.fs.find(sanity_configs, { path = fname, upward = true })[1]
    if found then
      on_dir(vim.fs.dirname(found))
    end
  end,
  init_options = {
    schemaPath = "./cms/schema.json",
    extensions = {
      paramTypeAnnotations = true,
    },
  },
}
