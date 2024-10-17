require("lspconfig.ui.windows").default_options = { border = "rounded" }
local lspconfig = require("lspconfig")

-- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations
lspconfig.ts_ls.setup({})
lspconfig.eslint.setup({
	on_attach = function(_, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
})
lspconfig.lua_ls.setup({
	-- stop the lua lsp complaining about calling `vim`
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})
lspconfig.cssls.setup({})
lspconfig.nixd.setup({})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "rounded",
})
