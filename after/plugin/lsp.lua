local lsp = require("lsp-zero")
local lspconfig = require('lspconfig')
local autocmd = vim.api.nvim_create_autocmd

lsp.preset("recommended")

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
  ['<CR>'] = cmp.mapping.confirm({ select = false }),
  ['<S-Space>'] = cmp.mapping.abort(),
  ['<C-Space>'] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

cmp.setup({
  -- add these back in if I decide I want bordered windows (need to pass in a few other options as well)
  --  window = {
  --    completion = cmp.config.window.bordered(),
  --    documentation = cmp.config.window.bordered(),
  --  },
  mapping = cmp.mapping.preset.insert({
    ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<S-Space>'] = cmp.mapping.abort(),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  preselect = cmp.PreselectMode.None,
  sources = {
    { name = 'nvim_lsp' }
  }
})

lsp.set_preferences({
  suggest_lsp_servers = true,
  sign_icons = {
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
  }
})
-- @NOTE re: styled components:
-- To get autocompletion/LSP support in styled-components, follow the Visual Studio instructions
-- here: https://github.com/styled-components/typescript-styled-plugin?tab=readme-ov-file#with-visual-studio
-- and then run `TSInstall css` in the nvim command line to get syntax highlighting
--
-- I might be able to get this working w/o needing to install the plugin into the project and instead use a global
-- config, but I haven't been able to get that to work yet, and it's not worth the time

autocmd("BufWritePre", {
  pattern = { '*.js', '*.jsx', '*.ts', '*.tsx' },
  callback = function()
    -- this makes it so that if eslint isn't installed in a project, we don't get an error on every save
    if vim.fn.exists(':EslintFixAll') > 0 then
      vim.cmd("EslintFixAll")
    end
    if vim.fn.exists(':Prettier') > 0 then
      vim.cmd('Prettier')
    end
  end
})

-- idk how to make this work, whatever
-- autocmd("BufWritePre", {
--   pattern = { '*.kt', '*.kts' },
--   callback = function()
--     vim.cmd("%! ktlint --format")
--   end
-- })


vim.lsp.buf.format {
  filter = function(client)
    return client.name ~= "yamlls" and client.name ~= "marksman"
  end
}

lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }
  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)


  local supported_types = {
    -- @TODO: make this a mapping for the ensure_installed so that I don't forget to add things
    -- in two places
    'javascriptreact',
    'typescriptreact',
    'typescript',
    'javascript',
    'lua',
    'go',
    'rust',
    'python',
    'kotlin',
    'gleam',
    'haskell',
  }

  autocmd("BufWritePre", {
    callback = function()
      local type = vim.bo.filetype
      if vim.tbl_contains(supported_types, type) then
        vim.lsp.buf.format()
      end
    end
  })
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    'ts_ls',
    'rust_analyzer',
    'eslint',
    -- 'pyright',
    'gopls',
    'jsonls',
    'bashls',
    'dockerls',
    'cssls',
    'marksman',
    'lua_ls',
    -- 'pylsp',
    'basedpyright',
    'kotlin_language_server',
    -- 'sqlls',
    'astro',
    'tailwindcss',
    -- 'denols',
    'hls',
  },
  handlers = {
    lsp.default_setup,
    lua_ls = lspconfig.lua_ls.setup {
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' }
          }
        }
      }
    },
    basedpyright = lspconfig.basedpyright.setup {
      -- settings = {
      --   basedpyright = {
      --     analysis = {
      --       autoSearchPaths = true,
      --       useLibraryCodeForTypes = true,
      --       diagnosticMode = "workspace",
      --     }
      --   }
      -- }
    },
    -- pylsp with mypy seems to be working fine after restarting the terminal, so will continue using that
    -- setup; if I get the freeze on save issue again, will try switching back
    -- pylsp with mypy seems to struggle a bit on really large files
    -- (eg. payments/models.py in PlushCare API is 1700 LOC), so might be worth switching back to see
    -- the difference
    -- if I want to use pyright, use the commented out setup function below
    --    pyright = lspconfig.pyright.setup {
    --      settings = {
    --        python = {
    --          analysis = {
    --            typeCheckingMode = "strict",
    --            autoSearchPaths = true,
    --            useLibraryCodeForTypes = true,
    --            diagnosticMode = "workspace",
    --            stubPath = vim.fn.stdpath('data') .. '/stubs'
    --          }
    --        }
    --      }
    --    },
    --  On my work computer, pylsp gets installed into ~/.local/share/nvim/mason/packages/python-lsp-server.
    --  To install type stubs and pylsp plugins I need to activate the venv in that folder, and then install
    --  them manually using pip in isolated mode, as otherwise I get AWS code artifact 401 errors.
    --
    --  ^ I'm leaving this here for future reference, but the problem was that my global pip config had been set to use
    --  PlushCare's AWS code artifact, so I had to delete my pip config in ~/.config/pip/pip.conf and everything is
    --  working fine now
    --
    --  Have to install mypy to get type checking with pylsp, instead of needing something like pyright.
    --  documenting some shit:
    --  - things seem to be working again now
    --  - do NOT install flake8 as a plugin to pylsp, it breaks... everything!
    --  - a lot of weirdness with mypy for type checking, unsure which venv it's actually using for the types
    --  - may need to install mypy into the venv that I'm using to run a specific project
    --  - something is fucked with Pydantic + mypy, yayyyyyy!
    --  -^ the problem here was that mypy doesn't type check the body of functions without type hints in the function
    --  signature AT ALL, so I needed to add settings.pylsp.plugins.pylsp_mypy.config.checked_untyped_defs = true
    --  -^ I should look into some other stuff w/ mypy, see if I can point it at the correct venv
    --  -^ looks like there's a mix of parsing libs installed in the current project venv as well as stubs in... somewhere!
    --  -^ might still need pyright for the things I want :((((((
    --  ^ OKAY: I need the stubs installed in the venv for the individual project, this is important to know
    -- pylsp = function()
    --   lspconfig.pylsp.setup({
    --     root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
    --     settings = {
    --       pylsp = {
    --         configurationSources = { "flake8" },
    --         plugins = {
    --           pycodestyle = {
    --             enabled = false,
    --           },
    --           mccabe = {
    --             enabled = false
    --           },
    --           pyflakes = {
    --             enabled = false
    --           },
    --           pylint = {
    --             enabled = false
    --           },
    --           flake8 = {
    --             enabled = true,
    --           },
    --           autopep8 = {
    --             enabled = true,
    --           },
    --           yapf = {
    --             enabled = false,
    --           },
    --           isort = {
    --             enabled = false,
    --           },
    --           -- pylsp_mypy = {
    --           --   enabled = true,
    --           --   config = {
    --           --     strict = true,
    --           --     follow_imports = true,
    --           --     check_untyped_defs = true,
    --           --   }
    --           -- },
    --         }
    --       },
    --     }
    --   })
    -- end,
    bashls = lspconfig.bashls.setup({
      cmd = { "bash-language-server", "start" },
      filetypes = { "sh", "zsh", "bash", ".bashrc" },
      root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
      settings = {
        bash = {
          filetypes = { "sh", "zsh", "bash" }
        }
      }
    }),
    yamlls = lspconfig.yamlls.setup({
      filetypes = { "yaml", "yml" }
    }),
    kotlin_language_server = lspconfig.kotlin_language_server.setup({
      cmd = { "kotlin-language-server" },
      filetypes = { "kotlin" },
    }),
    tailwindcss = lspconfig.tailwindcss.setup {
      filetypes = { "javascriptreact", "typescriptreact", "gleam", "html" }
    },
    eslint = lspconfig.eslint.setup {
      -- root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
      -- root_dir = function()
      --   return vim.fs.dirname(vim.fs.find({ 'eslint.config.mjs' }, { upward = true })[1])
      -- end,
      useFlatConfig = true,
    },
    gleam = lspconfig.gleam.setup {},
    hls = lspconfig.hls.setup {
      filetypes = { 'haskell', 'lhaskell', 'cabal' },
    },
    tsserver = lspconfig.tsserver.setup {
      root_dir = lspconfig.util.root_pattern("tsconfig.json"),
      single_file_support = false
    },
    -- denols = lspconfig.denols.setup {
    --   root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
    -- }
  }
})

lspconfig.gleam.setup {}

vim.diagnostic.config({
  virtual_text = true
})
