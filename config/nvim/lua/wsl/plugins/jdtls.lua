return { "mfussenegger/nvim-jdtls", ft = "java", dependencies = { "hrsh7th/cmp-nvim-lsp" }, config = function()
    vim.api.nvim_create_autocmd("FileType", { pattern = "java", group = vim.api.nvim_create_augroup("WslJava", { clear = true }), callback = function() require("wsl.java").setup() end })
    if vim.bo.filetype == "java" then require("wsl.java").setup() end
end }
