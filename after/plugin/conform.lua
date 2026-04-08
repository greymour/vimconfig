local biome_root_file = require("conform.util").root_file({
  "biome.json",
  "biome.jsonc",
})

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
    yaml = { "prettier", "biome", "biome-organize-imports" },
    astro = { "prettier", "biome", "biome-organize-imports" },
    kotlin = { "ktlint" },
  },
  formatters = {
    prettier = {
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
      require_cwd = true,
      cwd = biome_root_file,
    },
    ["biome-organize-imports"] = {
      require_cwd = true,
      cwd = biome_root_file,
    },
    ktlint = {
      command = "ktlint",
      args = { "-F", "$FILENAME" },
      stdin = false,
    },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
