return {
  cmd = { '/Users/kurt/code/groq-language-server/bin/groq-language-server.cjs', '--stdio' },
  filetypes = { 'groq', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  root_markers = { 'sanity.config.ts', 'sanity.config.js', 'sanity.config.tsx', 'package.json' },
  init_options = {
    schemaPath = "./cms/schema.json",
    extensions = {
      paramTypeAnnotations = true,
    },
  },
}
