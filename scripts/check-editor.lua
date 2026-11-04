local ok, err = xpcall(function()
    assert(vim.v.errmsg == "", vim.v.errmsg)
    assert(vim.fn.has("nvim-0.11.3") == 1, "Neovim 0.11.3+ required")
    for name, plugin in pairs(require("lazy.core.config").plugins) do
        assert(vim.fn.isdirectory(plugin.dir .. "/.git") == 1, "Plugin missing: " .. name)
    end
    require("telescope.builtin")
    require("conform")
    require("gitsigns")
    assert(vim.fn.exists(":Git") == 2, "Fugitive command missing")
    assert(vim.lsp.config.ts_ls.cmd, "TypeScript LSP config missing")
    assert(vim.lsp.config.bashls.cmd, "Bash LSP config missing")
    assert(vim.lsp.config.pyright.cmd, "Python LSP config missing")
end, debug.traceback)
if not ok then
    io.stderr:write(tostring(err) .. "\n")
    vim.cmd("cquit 1")
else
    print("Neovim plugin configuration passed.")
    vim.cmd("qa!")
end
