---@type vim.lsp.Config
return {
  cmd = { 'astro-ls', '--stdio' },
  filetypes = { 'astro' },
  init_options = {
    typescript = {
      -- Try local project TypeScript first, fall back to Mason-installed TypeScript
      tsdk = (function()
        local local_tsdk = vim.fn.getcwd() .. '/node_modules/typescript/lib'
        if vim.fn.isdirectory(local_tsdk) == 1 then
          return local_tsdk
        end
        -- Fallback to Mason's TypeScript installation
        local mason_tsdk = vim.fn.stdpath('data') .. '/mason/packages/typescript-language-server/node_modules/typescript/lib'
        if vim.fn.isdirectory(mason_tsdk) == 1 then
          return mason_tsdk
        end
        return local_tsdk -- Default to local even if not found
      end)()
    }
  },
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = 'all' },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      }
    }
  },
}
