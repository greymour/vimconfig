local util = require("conform.util")

local function read_json_file(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  local parsed_ok, data = ok and pcall(vim.json.decode, table.concat(lines, "\n"))

  return parsed_ok and data or nil
end

local function has_package_json_key(path, key)
  local package_json = vim.fs.joinpath(path, "package.json")
  local data = read_json_file(package_json)

  return data and data[key] ~= nil
end

local function root_file(files, package_json_key)
  return function(dirname)
    return vim.fs.root(dirname, function(name, path)
      return vim.tbl_contains(files, name)
        or (
          package_json_key
          and name == "package.json"
          and has_package_json_key(path, package_json_key)
        )
    end)
  end
end

local function cwd_from_root(root)
  return function(_, ctx)
    return root(ctx.dirname)
  end
end

local prettier_root_file = root_file({
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.json5",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  ".prettierrc.toml",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
  "prettier.config.ts",
}, "prettier")

local biome_root_file = root_file({
  "biome.json",
  "biome.jsonc",
}, "biome")

local oxfmt_root_file = root_file({
  ".oxfmtrc.json",
  ".oxfmtrc.jsonc",
  "oxfmt.config.ts",
})

local oxfmt_filetypes = {
  css = true,
  html = true,
  javascript = true,
  javascriptreact = true,
  json = true,
  jsonc = true,
  typescript = true,
  typescriptreact = true,
  yaml = true,
}

local function has_root(root, bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local dirname = filename ~= "" and vim.fs.dirname(filename) or nil

  return dirname and root(dirname) ~= nil
end

local function web_formatters(bufnr)
  local filetype = vim.bo[bufnr].filetype

  if oxfmt_filetypes[filetype] and has_root(oxfmt_root_file, bufnr) then
    return { "oxfmt" }
  end

  if has_root(prettier_root_file, bufnr) then
    return { "prettier" }
  end

  if has_root(biome_root_file, bufnr) then
    return { "biome", "biome-organize-imports" }
  end

  return {}
end

require("conform").setup({
  formatters_by_ft = {
    javascript = web_formatters,
    javascriptreact = web_formatters,
    typescript = web_formatters,
    typescriptreact = web_formatters,
    json = web_formatters,
    jsonc = web_formatters,
    css = web_formatters,
    html = web_formatters,
    yaml = web_formatters,
    astro = web_formatters,
    kotlin = { "ktlint" },
  },
  formatters = {
    prettier = {
      require_cwd = true,
      cwd = cwd_from_root(prettier_root_file),
    },
    biome = {
      require_cwd = true,
      cwd = cwd_from_root(biome_root_file),
    },
    ["biome-organize-imports"] = {
      require_cwd = true,
      cwd = cwd_from_root(biome_root_file),
    },
    oxfmt = {
      command = util.from_node_modules("oxfmt"),
      args = { "--stdin-filepath", "$FILENAME" },
      stdin = true,
      require_cwd = true,
      cwd = cwd_from_root(oxfmt_root_file),
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
