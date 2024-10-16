---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup({
	sync_install = false,
	auto_install = false,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})

