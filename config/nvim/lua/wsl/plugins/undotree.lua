return {
	"mbbill/undotree",

	config = function()
		vim.keymap.set("n", "<leader>nn", vim.cmd.UndotreeToggle)
	end,
}
