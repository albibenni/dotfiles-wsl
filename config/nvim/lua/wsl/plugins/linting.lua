return { "mfussenegger/nvim-lint", config = function()
    local lint = require("lint")
    local candidates = { python = { "pylint" }, css = { "stylelint" }, json = { "jsonlint" }, c = { "cpplint" } }
    local function run()
        local names = {}
        for _, name in ipairs(candidates[vim.bo.filetype] or {}) do
            local config = lint.linters[name]
            local command = type(config.cmd) == "function" and config.cmd() or config.cmd
            if vim.fn.executable(command) == 1 then names[#names + 1] = name end
        end
        -- Optional linters are quiet when absent; LSP diagnostics still work.
        if #names > 0 then lint.try_lint(names) end
    end
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, { group = vim.api.nvim_create_augroup("WslLint", { clear = true }), callback = run })
    vim.keymap.set("n", "<leader>l", run, { desc = "Lint current file" })
end }
