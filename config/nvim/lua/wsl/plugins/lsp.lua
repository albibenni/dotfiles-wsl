return { "neovim/nvim-lspconfig", dependencies = { "hrsh7th/cmp-nvim-lsp" }, config = function()
    vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
    vim.lsp.config("lua_ls", { settings = { Lua = { runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false }, telemetry = { enable = false } } } })
    vim.lsp.config("ts_ls", { init_options = { disableAutomaticTypingAcquisition = true }, before_init = function(params, config)
        -- Prefer project TypeScript when it has tsserver; otherwise use a separate
        -- TypeScript 6 install. Global TypeScript 7 remains unchanged.
        local path = config.root_dir and (config.root_dir .. "/node_modules/typescript/lib/tsserver.js")
        if not path or vim.fn.filereadable(path) ~= 1 then
            local data = vim.env.MISE_DATA_DIR or ((vim.env.XDG_DATA_HOME or ((vim.env.HOME or "") .. "/.local/share")) .. "/mise")
            local matches = vim.fn.glob(data .. "/installs/npm-typescript/6.*/node_modules/typescript/lib/tsserver.js", false, true)
            table.sort(matches, function(a, b)
                local av = a:match("/npm%-typescript/(6%.[^/]+)/")
                local bv = b:match("/npm%-typescript/(6%.[^/]+)/")
                return vim.version.cmp(av, bv) < 0
            end)
            path = matches[#matches]
        end
        if path then
            local options = vim.tbl_deep_extend("force", config.init_options or {}, { tsserver = { path = path } })
            config.init_options = options
            params.initializationOptions = options
        end
    end })
    for name, command in pairs({ ts_ls = "typescript-language-server", bashls = "bash-language-server", pyright = "pyright-langserver",
        lua_ls = "lua-language-server", gopls = "gopls", rust_analyzer = "rust-analyzer", zls = "zls",
        html = "vscode-html-language-server", cssls = "vscode-css-language-server", dockerls = "docker-langserver",
        tailwindcss = "tailwindcss-language-server", graphql = "graphql-lsp", emmet_ls = "emmet-ls", biome = "biome", svelte = "svelteserver", clangd = "clangd",
    }) do
        if vim.fn.executable(command) == 1 then vim.lsp.enable(name) end
    end
    vim.api.nvim_create_autocmd("LspAttach", { group = vim.api.nvim_create_augroup("WslLsp", { clear = true }), callback = function(event)
        local function map(keys, fn, desc) vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = desc }) end
        local b = require("telescope.builtin")
        map("gd", b.lsp_definitions, "Definition"); map("gr", b.lsp_references, "References")
        map("gI", b.lsp_implementations, "Implementation"); map("gD", vim.lsp.buf.declaration, "Declaration")
        map("<leader>D", b.lsp_type_definitions, "Type definition"); map("<leader>ds", b.lsp_document_symbols, "Document symbols")
        map("K", vim.lsp.buf.hover, "Documentation"); map("<C-k>", vim.lsp.buf.hover, "Documentation")
        map("<leader>rn", vim.lsp.buf.rename, "Rename"); map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    end })
end }
