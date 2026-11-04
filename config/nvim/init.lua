vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.winborder = "rounded"
-- No forced whitespace edits or formatting on save.
local config = vim.fn.stdpath("config")
local repo = vim.fn.fnamemodify(vim.fn.resolve(config .. "/init.lua"), ":h:h:h")
local copy = repo .. "/bin/clipboard-copy"
local paste = repo .. "/bin/clipboard-paste"
vim.g.clipboard = {
    name = "WSL",
    copy = { ["+"] = { copy }, ["*"] = { copy } },
    paste = { ["+"] = { paste }, ["*"] = { paste } },
    cache_enabled = 0,
}
vim.opt.clipboard = "unnamedplus"
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("n", "<leader>e", "<cmd>Explore<cr>", { desc = "File browser" })
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
local lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazy) then
    if vim.env.DOTFILES_WSL_OFFLINE == "1" then return end
    local output = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazy })
    if vim.v.shell_error ~= 0 then error("Cannot install lazy.nvim: " .. output) end
end
vim.opt.rtp:prepend(lazy)
require("lazy").setup({
    { "folke/tokyonight.nvim", priority = 1000, config = function() vim.cmd.colorscheme("tokyonight-night") end },
    { "nvim-telescope/telescope.nvim", version = "*", dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({ defaults = { file_ignore_patterns = { "node_modules/", "%.git/" } } })
            local b = require("telescope.builtin")
            vim.keymap.set("n", "<leader>pf", b.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>ps", b.live_grep, { desc = "Search text" })
            vim.keymap.set("n", "<leader>pb", b.buffers, { desc = "Buffers" })
            vim.keymap.set("n", "<leader>vh", b.help_tags, { desc = "Help" })
        end },
    { "lewis6991/gitsigns.nvim", opts = {} },
    { "tpope/vim-fugitive" },
    { "neovim/nvim-lspconfig", config = function()
        -- Language servers are installed by scripts/install-tools.sh, not during editor startup.
        for name, command in pairs({ ts_ls = "typescript-language-server", bashls = "bash-language-server", pyright = "pyright-langserver" }) do
            if vim.fn.executable(command) == 1 then vim.lsp.enable(name) end
        end
        vim.api.nvim_create_autocmd("LspAttach", { callback = function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client:supports_method("textDocument/completion") then
                vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
            end
            local opts = { buffer = event.buf }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        end })
    end },
    { "stevearc/conform.nvim", opts = { formatters_by_ft = {
        javascript = { "prettier" }, typescript = { "prettier" },
        javascriptreact = { "prettier" }, typescriptreact = { "prettier" },
        json = { "prettier" }, yaml = { "prettier" }, markdown = { "prettier" },
        html = { "prettier" }, css = { "prettier" }, sh = { "shfmt" }, python = { "black" },
    } }, config = function(_, opts)
        require("conform").setup(opts)
        vim.keymap.set({ "n", "v" }, "<leader>f", function()
            require("conform").format({ async = true, lsp_format = "fallback" })
        end, { desc = "Format" })
    end },
}, { checker = { enabled = false }, change_detection = { notify = false } })
