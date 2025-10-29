local util = require 'lspconfig.util'

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local cmd = 'biome'
    local local_cmd = (config or {}).root_dir and config.root_dir .. '/node_modules/.bin/biome'
    if local_cmd and vim.fn.executable(local_cmd) == 1 then
      cmd = local_cmd
    end
    return vim.lsp.rpc.start({ cmd, 'lsp-proxy' }, dispatchers)
  end,
  filetypes = {
    'astro',
    'css',
    'graphql',
    'html',
    'javascript',
    'javascriptreact',
    'json',
    'jsonc',
    'svelte',
    'typescript',
    'typescript.tsx',
    'typescriptreact',
    'vue',
  },
  workspace_required = true,
  root_dir = function(bufnr, on_dir)
    -- The project root is where the LSP can be started from
    -- As stated in the documentation above, this LSP supports monorepos and simple projects.
    -- We select then from the project root, which is identified by the presence of a package
    -- manager lock file.
    local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
    -- Give the root markers equal priority by wrapping them in a table
    root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers } or root_markers
    local project_root = vim.fs.root(bufnr, root_markers)
    if not project_root then
      return
    end

    -- We know that the buffer is using Biome if it has a config file
    -- in its directory tree.
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local biome_config_files = { 'biome.json', 'biome.jsonc' }
    biome_config_files = util.insert_package_json(biome_config_files, 'biome', filename)
    local is_buffer_using_biome = vim.fs.find(biome_config_files, {
      path = filename,
      type = 'file',
      limit = 1,
      upward = true,
      stop = vim.fs.dirname(project_root),
    })[1]
    if not is_buffer_using_biome then
      return
    end

    on_dir(project_root)
  end,
  settings = {
    -- Enable formatting capabilities
    ['biome.lsp.formatting'] = true,
  },
  -- Ensure Biome handles formatting for supported files
  capabilities = {
    documentFormattingProvider = true
  },
  on_attach = function(client, bufnr)
    -- Explicitly enable formatting for this client
    client.server_capabilities.documentFormattingProvider = true

    -- Get the file path and create a buffer-specific format command
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')

    -- Only set up formatting for supported filetypes
    local supported_filetypes = {
      javascript = true,
      javascriptreact = true,
      typescript = true,
      typescriptreact = true
    }

    if supported_filetypes[filetype] then
      -- Create a buffer-specific autocmd group
      local group_name = "BiomeFormatOnSave_" .. bufnr
      local group = vim.api.nvim_create_augroup(group_name, { clear = true })

      -- vim.api.nvim_create_autocmd("BufWritePre", {
      --   group = group,
      --   buffer = bufnr,
      --   callback = function()
      --     -- Get the root directory where biome.json is located
      --     local config_file = vim.fs.find({ 'biome.json', 'biome.jsonc' }, {
      --       path = filepath,
      --       upward = true,
      --       type = 'file',
      --       limit = 1
      --     })[1]

      --     -- If config file exists, get its directory to use as cwd
      --     local cwd = nil
      --     if config_file then
      --       cwd = vim.fs.dirname(config_file)
      --     end

      --     -- Save current cursor position
      --     local cursor_pos = vim.api.nvim_win_get_cursor(0)

      --     -- Get file path relative to cwd if possible
      --     local format_path = filepath
      --     if cwd then
      --       -- Try to get relative path if file is within the cwd
      --       if filepath:find(cwd, 1, true) == 1 then
      --         format_path = filepath:sub(#cwd + 2)   -- +2 to account for trailing slash
      --       end
      --     end

      --     -- Use the system command directly instead of LSP
      --     vim.cmd('silent !biome format --write "' .. format_path .. '"')

      --     -- Force buffer reload from disk
      --     vim.cmd('edit!')

      --     -- Restore cursor position
      --     vim.api.nvim_win_set_cursor(0, cursor_pos)
      --   end,
      -- })
    end
  end,
}
