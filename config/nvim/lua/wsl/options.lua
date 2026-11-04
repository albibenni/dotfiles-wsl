vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitright = true
vim.opt.splitbelow = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
-- Use Neovim's state directory, not another editor's ~/.vim directory.
local undo = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undo, "p")
vim.opt.undodir = undo
vim.opt.undofile = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.spelllang = { "en", "it" }
vim.opt.spell = false
vim.opt.colorcolumn = "120"
vim.opt.winborder = "rounded"
vim.opt.timeoutlen = 500
vim.filetype.add({ extension = { templ = "templ" } })
local group = vim.api.nvim_create_augroup("DotfilesWsl", { clear = true })
vim.api.nvim_create_autocmd("FileType", { group = group, callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
end })
vim.api.nvim_create_autocmd("TextYankPost", { group = group, callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 80 })
end })
-- No forced whitespace stripping, Copilot commands, or formatting on save.
