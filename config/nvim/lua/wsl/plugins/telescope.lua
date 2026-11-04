return { "nvim-telescope/telescope.nvim", version = "*", dependencies = {
    "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
}, config = function()
    local t = require("telescope")
    local b = require("telescope.builtin")
    local a = require("telescope.actions")
    t.setup({ defaults = {
        path_display = { "filename_first" }, file_ignore_patterns = { "%.git/", "node_modules/" },
        vimgrep_arguments = { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case", "--hidden", "--glob", "!.git/*" },
        mappings = { i = { ["<C-k>"] = a.move_selection_previous, ["<C-j>"] = a.move_selection_next,
            ["<C-q>"] = a.send_selected_to_qflist + a.open_qflist, ["<Esc>"] = a.close } },
    } })
    t.load_extension("fzf")
    local map = vim.keymap.set
    map("n", "<leader>pf", b.find_files, { desc = "Find files" })
    map("n", "<C-p>", b.git_files, { desc = "Git files" })
    map("n", "<leader>ps", b.live_grep, { desc = "Search text" })
    map("n", "<leader>pb", b.buffers, { desc = "Buffers" })
    map("n", "<leader>pwc", function() b.grep_string({ search = vim.fn.expand("<cWORD>") }) end)
    map("n", "<leader>pwa", function() b.grep_string({ search = vim.fn.input("Grep > ") }) end)
    map("n", "<leader>pc", b.grep_string, { desc = "Find current word" })
    map("n", "<leader>pt", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs" })
    map("n", "<leader>vh", b.help_tags, { desc = "Help tags" })
end }
