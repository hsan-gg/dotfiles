vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Formatting is handled by conform.nvim (plugins/format.lua)

-- ========================================
-- Server configs (only put overrides here)
-- ========================================

local servers = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },
  pyright = {},
  ts_ls = {},
  html = {},
  cssls = {},
  bashls = {},
  clangd = {},
  jsonls = {},
}

for name, opts in pairs(servers) do
  vim.lsp.config(name, vim.tbl_deep_extend("force", { capabilities = capabilities }, opts))
end

vim.lsp.enable(vim.tbl_keys(servers))

-- ========================================
-- Diagnostics
-- ========================================

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
})

-- ========================================
-- LSP Keymaps (buffer-local, set on attach)
-- ========================================

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local buf = event.buf

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
    end

    -- Navigation
    map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
    -- References: use the built-in `grr` (plain `gr` would shadow grn/gra/grr/gri)
    map("n", "gI", vim.lsp.buf.implementation, "Go to Implementation")

    -- Documentation
    map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
    map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

    -- Refactoring
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  end,
})

-- ========================================
-- Diagnostic Keymaps (global, not attach-dependent)
-- ========================================

-- [d / ]d (prev/next diagnostic) are built in since Neovim 0.11
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show Diagnostic" })
vim.keymap.set("n", "<leader>xx", vim.diagnostic.setloclist, { desc = "Show Diagnostics" })