local ok, err = xpcall(function()
    local languages = require("wsl.parsers")
    -- Frozen master uses TSInstallSync, not main's incompatible async install API.
    local missing = {}
    for _, language in ipairs(languages) do
        local ok, loaded = pcall(vim.treesitter.language.add, language)
        if not ok or not loaded then missing[#missing + 1] = language end
    end
    -- Installed parsers prompt on TSInstallSync; only request missing languages.
    if #missing > 0 then vim.cmd("TSInstallSync " .. table.concat(missing, " ")) end
    for _, language in ipairs(languages) do
        local ok, loaded, reason = pcall(vim.treesitter.language.add, language)
        assert(ok and loaded, "Parser failed to install: " .. language .. ": " .. tostring(reason or loaded))
    end
end, debug.traceback)
if not ok then io.stderr:write(tostring(err) .. "\n"); vim.cmd("cquit 1") end
print("Treesitter parsers installed and loadable.")
vim.cmd("qa!")
