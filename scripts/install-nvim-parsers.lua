local ok, err = xpcall(function()
    local languages = require("wsl.parsers")
    -- Frozen master uses TSInstallSync, not main's incompatible async install API.
    vim.cmd("TSInstallSync " .. table.concat(languages, " "))
    for _, language in ipairs(languages) do
        assert(pcall(vim.treesitter.language.add, language), "Parser failed to install: " .. language)
    end
end, debug.traceback)
if not ok then io.stderr:write(tostring(err) .. "\n"); vim.cmd("cquit 1") end
print("Treesitter parsers installed and loadable.")
vim.cmd("qa!")
