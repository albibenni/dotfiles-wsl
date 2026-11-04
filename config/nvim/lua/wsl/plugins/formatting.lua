return { "stevearc/conform.nvim", config = function()
    local web = { "vp_fmt", "biome", "prettier", stop_after_first = true }
    require("conform").setup({ formatters_by_ft = {
        sh = { "shfmt" }, bash = { "shfmt" }, javascript = web, typescript = web,
        javascriptreact = web, typescriptreact = web, svelte = web, css = web, html = web, json = web, graphql = web,
        yaml = { "yamlfmt", "prettier", stop_after_first = true }, markdown = { "prettier" }, liquid = { "prettier" },
        rust = { "rustfmt" }, c = { "clang_format" }, cpp = { "clang_format" }, go = { "gofmt" },
        lua = { "stylua" }, python = { "isort", "black" }, java = { "google_java_format" },
    }, formatters = {
        vp_fmt = { command = "vp", args = { "fmt", "--stdin-filepath", "$FILENAME" }, stdin = true,
            cwd = require("conform.util").root_file({ "vite.config.ts", "vite.config.js", "vite.config.mts", "vite.config.mjs" }), require_cwd = true },
        shfmt = { prepend_args = { "-i", "2" } },
    } })
    vim.keymap.set({ "n", "v" }, "<leader>f", function()
        require("conform").format({ async = false, timeout_ms = 3000, lsp_format = "fallback" })
    end, { desc = "Format file or selection" })
end }
