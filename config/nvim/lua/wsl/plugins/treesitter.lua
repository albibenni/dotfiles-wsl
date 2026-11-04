return { "nvim-treesitter/nvim-treesitter", branch = "master", lazy = false, build = ":TSUpdate", dependencies = {
    { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" }, "windwp/nvim-ts-autotag",
}, config = function()
    -- main requires Neovim 0.12; master is the compatible 0.11 API.
    require("nvim-treesitter.configs").setup({
        ensure_installed = {}, auto_install = false, highlight = { enable = true },
        indent = { enable = true },
        textobjects = {
            select = { enable = true, lookahead = true, keymaps = {
                ["a="] = "@assignment.outer", ["i="] = "@assignment.inner", ["l="] = "@assignment.lhs", ["r="] = "@assignment.rhs",
                ["aa"] = "@parameter.outer", ["ia"] = "@parameter.inner",
                ["ai"] = "@conditional.outer", ["ii"] = "@conditional.inner",
                ["al"] = "@loop.outer", ["il"] = "@loop.inner",
                ["af"] = "@call.outer", ["if"] = "@call.inner",
                ["am"] = "@function.outer", ["im"] = "@function.inner",
                ["ac"] = "@class.outer", ["ic"] = "@class.inner",
            } },
            swap = { enable = true, swap_next = { ["<leader>na"] = "@parameter.inner", ["<leader>nm"] = "@function.outer" },
                swap_previous = { ["<leader>pa"] = "@parameter.inner", ["<leader>pm"] = "@function.outer" } },
            move = { enable = true, set_jumps = true,
                goto_next_start = { ["]f"] = "@call.outer", ["]m"] = "@function.outer", ["]c"] = "@class.outer", ["]i"] = "@conditional.outer", ["]l"] = "@loop.outer" },
                goto_previous_start = { ["[f"] = "@call.outer", ["[m"] = "@function.outer", ["[c"] = "@class.outer", ["[i"] = "@conditional.outer", ["[l"] = "@loop.outer" },
                goto_next_end = { ["]F"] = "@call.outer", ["]M"] = "@function.outer", ["]C"] = "@class.outer" },
                goto_previous_end = { ["[F"] = "@call.outer", ["[M"] = "@function.outer", ["[C"] = "@class.outer" },
            },
        },
    })
    require("nvim-ts-autotag").setup({})
end }
