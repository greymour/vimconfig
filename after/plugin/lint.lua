local lint = require("lint")

local oxlint_config_files = {
  ".oxlintrc.json",
  "oxlint.config.ts",
}

local oxlint_filetypes = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}

local function oxlint_root(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local dirname = filename ~= "" and vim.fs.dirname(filename) or nil

  return dirname and vim.fs.root(dirname, oxlint_config_files)
end

lint.linters.oxlint = {
  cmd = function()
    local local_binary = vim.fn.fnamemodify("./node_modules/.bin/oxlint", ":p")

    return vim.loop.fs_stat(local_binary) and local_binary or "oxlint"
  end,
  args = { "--format", "unix" },
  stdin = false,
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
    source = "oxlint",
    severity = vim.diagnostic.severity.WARN,
  }),
}

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("my.lint", { clear = true }),
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype
    local root = oxlint_filetypes[filetype] and oxlint_root(args.buf)

    if not root then
      return
    end

    lint.try_lint("oxlint", { cwd = root })
  end,
})
