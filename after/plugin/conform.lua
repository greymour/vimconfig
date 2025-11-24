require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettier", "biome", "biome-organize-imports" },
    javascriptreact = { "prettier", "biome", "biome-organize-imports" },
    typescript = { "prettier", "biome", "biome-organize-imports" },
    typescriptreact = { "prettier", "biome", "biome-organize-imports" },
    json = { "prettier", "biome", "biome-organize-imports" },
    jsonc = { "prettier", "biome", "biome-organize-imports" },
    css = { "prettier", "biome", "biome-organize-imports" },
    html = { "prettier", "biome", "biome-organize-imports" },
    markdown = { "prettier", "biome", "biome-organize-imports" },
    yaml = { "prettier", "biome", "biome-organize-imports" },
    astro = { "prettier", "biome", "biome-organize-imports" },
    kotlin = { "ktlint" },
  },
  formatters = {
    prettier = {
      -- Specify all config files prettier looks for
      require_cwd = true,
      cwd = require("conform.util").root_file({
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.yml",
        ".prettierrc.yaml",
        ".prettierrc.json5",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.mjs",
        "prettier.config.js",
        "prettier.config.cjs",
        "prettier.config.mjs",
        "package.json",
      }),
    },
    biome = {
      "biome.json",
    },
    ktlint = {
      command = "ktlint",
      args = { "-F", "$FILENAME" },
      stdin = false,
    },
  },
  -- Format on save
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
