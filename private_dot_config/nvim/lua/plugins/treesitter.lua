vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
})

-- nvim-treesitter `main` branch API (the old `nvim-treesitter.configs` module no longer exists).
-- Building parsers needs the `tree-sitter` CLI (pacman -S tree-sitter-cli) and a C compiler.
local ts = require("nvim-treesitter")
local can_build = vim.fn.executable("tree-sitter") == 1

local wanted = {
  "bash", "c", "cpp", "css", "html", "javascript", "json", "lua", "markdown",
  "markdown_inline", "python", "rust", "typescript", "tsx", "vim", "vimdoc", "yaml",
}

if can_build then
  ts.install(wanted) -- async; already-installed parsers are skipped
else
  vim.notify_once("treesitter: install tree-sitter-cli to build parsers", vim.log.levels.WARN)
end

local available = {}
for _, lang in ipairs(ts.get_available()) do
  available[lang] = true
end

vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
    -- auto-install parsers for other languages on first open
    if can_build and available[lang] and not vim.list_contains(ts.get_installed(), lang) then
      ts.install(lang)
    end
    if pcall(vim.treesitter.start, ev.buf, lang) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
