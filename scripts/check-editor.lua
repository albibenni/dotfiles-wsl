local errors = {}
local notify = vim.notify
vim.notify = function(message, level, opts)
    if level == vim.log.levels.ERROR then errors[#errors + 1] = tostring(message) end
    return notify(message, level, opts)
end
local ok, err = xpcall(function()
    assert(vim.v.errmsg == "", vim.v.errmsg)
    assert(vim.fn.has("nvim-0.11.3") == 1, "Neovim 0.11.3+ required")
    local names = {}
    for name, plugin in pairs(require("lazy.core.config").plugins) do
        assert(vim.fn.isdirectory(plugin.dir .. "/.git") == 1, "Plugin missing: " .. name)
        names[#names + 1] = name
    end
    require("lazy").load({ plugins = names })
    vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
    for _, module in ipairs({ "telescope.builtin", "conform", "gitsigns", "nvim-tree", "lualine", "harpoon", "cmp", "luasnip", "ibl", "trouble", "flash", "markview", "lint" }) do
        require(module)
    end
    require("telescope").load_extension("fzf")
    assert(vim.fn.exists(":Git") == 2, "Fugitive command missing")
    assert(vim.fn.exists(":NvimTreeToggle") == 2, "File tree command missing")
    assert(vim.lsp.config.ts_ls.cmd and vim.lsp.config.bashls.cmd and vim.lsp.config.pyright.cmd)
    assert(vim.o.colorcolumn == "120" and vim.o.wrap == false and vim.o.splitbelow == false)
    assert(vim.fn.maparg("<leader>ts", "n", false, true).desc == "Toggle spellcheck")
    assert(vim.fn.maparg("<C-f>", "n", false, true).desc == "Tmux project picker")
    assert(vim.fn.maparg("<leader>ee", "n") ~= "")
    assert(require("lualine").get_config().options.theme.inactive.a.fg ~= nil, "Inactive lualine foreground missing")
    for _, language in ipairs(require("wsl.parsers")) do
        local ok, loaded, reason = pcall(vim.treesitter.language.add, language)
        assert(ok and loaded, "Parser unavailable: " .. language .. ": " .. tostring(reason or loaded))
    end
    vim.cmd("NvimTreeOpen")
    assert(vim.bo.filetype == "NvimTree", "File tree did not open")
    vim.cmd("NvimTreeClose")
    vim.wait(100)
    assert(#errors == 0, table.concat(errors, "\n"))
    assert(vim.v.errmsg == "", vim.v.errmsg)
end, debug.traceback)
vim.notify = notify
if not ok then
    io.stderr:write(tostring(err) .. "\n")
    vim.cmd("cquit 1")
else
    print("Neovim plugins, UI, mappings, native fzf and parsers passed.")
    vim.cmd("qa!")
end
