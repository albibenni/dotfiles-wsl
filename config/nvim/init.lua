-- Resolve this file so direct `nvim -u PATH` tests work as well as the symlink.
local config = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
vim.opt.rtp:prepend(config)
vim.g.dotfiles_wsl_root = vim.fn.fnamemodify(vim.fn.resolve(config .. "/init.lua"), ":h:h:h")
require("wsl.options")
require("wsl.keymaps")
local copy = vim.g.dotfiles_wsl_root .. "/bin/clipboard-copy"
local paste = vim.g.dotfiles_wsl_root .. "/bin/clipboard-paste"
vim.g.clipboard = {
    name = "WSL", copy = { ["+"] = { copy }, ["*"] = { copy } },
    paste = { ["+"] = { paste }, ["*"] = { paste } }, cache_enabled = 0,
}
vim.opt.clipboard = "unnamedplus"
local lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazy) then
    if vim.env.DOTFILES_WSL_OFFLINE == "1" then return end
    local output = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazy })
    if vim.v.shell_error ~= 0 then error("Cannot install lazy.nvim: " .. output) end
end
vim.opt.rtp:prepend(lazy)
require("lazy").setup({ { import = "wsl.plugins" } }, {
    lockfile = config .. "/lazy-lock.json",
    install = { missing = vim.env.DOTFILES_WSL_OFFLINE ~= "1" },
    checker = { enabled = false }, change_detection = { notify = false },
})
-- Explicit user extension outside the tracked/symlinked Neovim directory.
local local_config = (vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")) .. "/nvim-local.lua"
if vim.fn.filereadable(local_config) == 1 then dofile(local_config) end
