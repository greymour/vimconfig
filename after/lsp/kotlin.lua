local root_files = {
  'settings.gradle',     -- Gradle (multi-project)
  'settings.gradle.kts', -- Gradle (multi-project)
  'build.xml',           -- Ant
  'pom.xml',             -- Maven
  'build.gradle',        -- Gradle
  'build.gradle.kts',    -- Gradle
  '.bazelrc',
}

return {
  filetypes = { 'kotlin' },
  root_markers = root_files,
  cmd = { 'kotlin-language-server' },
  init_options = {
    storagePath = vim.fs.root(vim.fn.expand '%:p:h', root_files),
  },
  settings = {
    kotlin = {
      compiler = {
        jvm = {
          target = '17',
        },
      },
      formatting = {
        enabled = true,
      },
      linting = {
        enabled = true,
      },
      externalSources = {
        useKtlint = true,
        autoFormat = true,
      },
    },
  },
}
