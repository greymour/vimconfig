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
        -- maxTsServerMemory = 8192, -- default to 8gb of memory
        nodePath = "node",
        logLevel = "off",
        watchOptions = {
          watchFile = "useFsEvents",
          watchDirectory = "useFsEvents",
          excludeDirectories = {
            "**/node_modules",
            "**/.git",
            "**/dist",
            "**/build",
            "**/.next",
            "**/coverage",
            "**/.turbo",
            "**/.cache"
          }
        },
        -- Exclude large directories
        exclude = {
          "node_modules",
          ".git",
          "dist",
          "build",
          ".next",
          "**/*.spec.ts",
          "**/*.test.ts",
          "coverage",
          ".turbo"
        },
      },
      -- PERFORMANCE OPTIMIZATIONS for large projects
      disableAutomaticTypingAcquisition = true,  -- Stop auto-downloading @types packages
      -- Preferences for faster operations
      preferences = {
        includeCompletionsForModuleExports = true,
        includeCompletionsWithInsertText = true,
        -- Faster import suggestions (less complete but quicker)
        includeCompletionsForImportStatements = true,
        includeAutomaticOptionalChainCompletions = false,  -- Reduce noise
        includeCompletionsWithSnippetText = false,         -- Faster completions
        -- Speed up signature help
        providePrefixAndSuffixTextForRename = false,
      },
      -- Disable expensive features in large projects
      implementationsCodeLens = { enabled = false },
      referencesCodeLens = { enabled = false },
      -- Format settings
      format = {
        enable = false,  -- We use Biome for formatting
      },
    },
    javascript = {
      -- Mirror TypeScript settings for JS files
      disableAutomaticTypingAcquisition = true,
      format = {
        enable = false,
      },
    },
  },
  on_attach = function(client)
    -- this is important, otherwise tsserver will format ts/js
    -- files which we *really* don't want.
    client.server_capabilities.documentFormattingProvider = false

    -- PERFORMANCE: Disable semantic tokens - huge win for large files
    client.server_capabilities.semanticTokensProvider = nil

    -- Get the Biome client if it's attached to this buffer
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
    for _, c in ipairs(clients) do
      if c.name == "biome" then
        -- Re-enable formatting for Biome
        c.server_capabilities.documentFormattingProvider = true
        break
      end
    end
  end,
}
