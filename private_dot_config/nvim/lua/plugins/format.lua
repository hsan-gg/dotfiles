vim.pack.add({
  "https://github.com/stevearc/conform.nvim",
})

-- Real formatters per language; falls back to the LSP formatter when none is listed.
require("conform").setup({
  formatters_by_ft = {
    python          = { "ruff_organize_imports", "ruff_format" },
    lua             = { "stylua" },
    c               = { "clang_format" },
    cpp             = { "clang_format" },
    javascript      = { "prettier" },
    javascriptreact = { "prettier" },
    typescript      = { "prettier" },
    typescriptreact = { "prettier" },
    css             = { "prettier" },
    html            = { "prettier" },
    json            = { "prettier" },
    yaml            = { "prettier" },
    markdown        = { "prettier" },
  },
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = { timeout_ms = 1000 },
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
  require("conform").format({ async = true })
end, { desc = "Format" })
