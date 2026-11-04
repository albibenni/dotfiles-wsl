return { "folke/zen-mode.nvim", opts = { window = { width = 90 } }, keys = {
    { "<leader>zz", function() require("zen-mode").toggle({ window = { width = 90, options = { number = true, relativenumber = true } } }) end, desc = "Zen mode" },
    { "<leader>zZ", function() require("zen-mode").toggle({ window = { width = 80, options = { number = false, relativenumber = false, colorcolumn = "" } } }) end, desc = "Zen reading mode" },
} }
