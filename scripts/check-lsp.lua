-- Integration check: initialize real servers and inspect diagnostics on temporary files.
local ok, err = xpcall(function()
    local directory = vim.fn.tempname()
    vim.fn.mkdir(directory, "p")
    vim.fn.writefile({ '{"compilerOptions":{"strict":true},"include":["*.ts"]}' }, directory .. "/tsconfig.json")
    vim.fn.writefile({ '{}' }, directory .. "/package.json")
    vim.fn.writefile({ '{}' }, directory .. "/package-lock.json")
    vim.fn.writefile({ '[tool.pyright]', 'typeCheckingMode = "basic"' }, directory .. "/pyproject.toml")
    local cases = {
        { name = "ts_ls", file = "sample.ts", text = 'const amount: number = "wrong";', code = 2322 },
        { name = "pyright", file = "sample.py", text = 'amount: int = "wrong"', code = "reportAssignmentType" },
        { name = "bashls", file = "sample.sh", text = '#!/usr/bin/env bash\necho "$HOME"' },
        { name = "lua_ls", file = "sample.lua", text = 'local amount = 1\nprint(amount)' },
    }
    vim.cmd.cd(directory)
    for _, case in ipairs(cases) do
        vim.fn.writefile(vim.split(case.text, "\n"), directory .. "/" .. case.file)
        vim.cmd.edit(directory .. "/" .. case.file)
        local buffer = vim.api.nvim_get_current_buf()
        local ready = vim.wait(30000, function()
            for _, client in ipairs(vim.lsp.get_clients({ bufnr = buffer, name = case.name })) do
                if client.initialized then return true end
            end
            return false
        end, 100)
        assert(ready, "Language server failed to initialize: " .. case.name)
        if case.code then
            local diagnosed = vim.wait(20000, function()
                for _, diagnostic in ipairs(vim.diagnostic.get(buffer)) do
                    if diagnostic.code == case.code then return true end
                end
                return false
            end, 100)
            assert(diagnosed, "Expected type error not reported by " .. case.name .. ": " .. vim.inspect(vim.diagnostic.get(buffer)))
        end
        local parser = vim.treesitter.get_parser(buffer)
        assert(parser:parse()[1], "Parser did not parse " .. case.file)
        print(case.name .. ": initialized" .. (case.code and "; type diagnostic verified" or "; parser verified"))
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = buffer })) do client:stop(true) end
        vim.cmd("enew!")
    end
    -- Exercise an actual formatter without modifying a user's file.
    vim.bo.filetype = "typescript"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'const thing={x:1,y:2}' })
    local formatting_error
    require("conform").format({ bufnr = 0, async = false, timeout_ms = 10000, formatters = { "prettier" } }, function(error) formatting_error = error end)
    assert(not formatting_error, tostring(formatting_error))
    assert(vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == 'const thing = { x: 1, y: 2 };', "Prettier did not format the buffer")
end, debug.traceback)
for _, client in ipairs(vim.lsp.get_clients()) do client:stop(true) end
if not ok then io.stderr:write(tostring(err) .. "\n"); vim.cmd("cquit 1") end
print("Real LSP diagnostics and Prettier formatting passed.")
vim.cmd("qa!")
