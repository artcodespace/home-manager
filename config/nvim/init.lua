vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, " ", "<nop>", { silent = true })

-- PLUGIN KEYBINDS
local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>f", fzf.files)
vim.keymap.set("n", "<leader>s", fzf.grep_project)
vim.keymap.set("n", "<leader>d", fzf.lsp_document_diagnostics)
vim.keymap.set("n", "<leader>o", fzf.lsp_document_symbols)
vim.keymap.set("n", "<leader>O", fzf.lsp_live_workspace_symbols)
vim.keymap.set("n", "gr", fzf.lsp_references)
vim.keymap.set("n", "gd", fzf.lsp_definitions)
vim.keymap.set("n", "<leader>h", fzf.helptags)
vim.keymap.set("n", "<leader><leader>", fzf.resume)

-- AUTOCOMMANDS
-- Use LspAttach to set mapping after the language server attaches
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		-- these could potentially be guarded, see :h lsp-config
		local opts = { buffer = args.buf }
		vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>c", vim.lsp.buf.code_action, opts)
		vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
	end,
})
-- Start neovim with fzf open if no arguments passed
vim.api.nvim_create_autocmd("VimEnter", {
	pattern = "*",
	callback = function()
		if next(vim.fn.argv()) == nil then
			require("fzf-lua").files()
		end
	end,
})
-- Don't show columns in these filetypes
vim.api.nvim_create_autocmd("filetype", {
	pattern = { "netrw", "qf", "help" },
	callback = function()
		vim.opt_local.colorcolumn = ""
		vim.opt_local.cursorcolumn = false
	end,
})
-- add abbreviations to these filetypes
vim.api.nvim_create_autocmd("filetype", {
	pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	callback = function()
		vim.cmd("iab <buffer> tbitd toBeInTheDocument()")
		vim.cmd("iab <buffer> fna () => {}")
	end,
})
-- What was previously in /after/ftplugin/netrw.lua
vim.api.nvim_create_autocmd("filetype", {
	pattern = "netrw",
	callback = function()
		-- https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer/
		vim.g.netrw_banner = 0
		vim.g.netrw_winsize = 30
		vim.g.netrw_altfile = 1 -- make <C-6> go back to prev file, not netrw
		vim.g.netrw_localcopydircmd = "cp -r" -- allow whole folder copying
		function NetrwWinBar()
			return "%#Normal#  %t %*%=%#Normal# 󰋞 " .. vim.fn.getcwd() .. " "
		end
		vim.opt_local.winbar = "%{%v:lua.NetrwWinBar()%}"
		vim.keymap.set("n", "h", "-", { remap = true, buffer = true })
		vim.keymap.set("n", "l", "<cr>", { remap = true, buffer = true })
		vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { remap = true, buffer = true })
	end,
})

-- KEYBINDS
local ERROR = { severity = vim.diagnostic.severity.ERROR }
vim.keymap.set("n", "<Esc>", function()
	local filetype = vim.bo.filetype
	local is_netrw = filetype == "netrw"
	local is_qf_or_help = filetype == "qf" or filetype == "help"
	local has_highlights = vim.v.hlsearch == 1

	if has_highlights then
		vim.cmd("nohls")
	elseif is_qf_or_help then
		vim.cmd("close")
	elseif is_netrw then
		vim.cmd("Rex")
	end
end, { silent = true })
vim.keymap.set("n", "<leader>e", "<cmd>Ex<cr>", { silent = true })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { silent = true })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { silent = true })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev(ERROR)
end, { silent = true })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next(ERROR)
end, { silent = true })
vim.keymap.set("i", "<C-j>", "<C-x><C-o>", { silent = true }) -- Lsp completion
-- TODO >>> combine this investigation with tsc.nvim fork
-- vim.api.nvim_create_user_command("Tsc", function()
-- 	local ts_root = vim.fs.root(0, "tsconfig") -- may need updating in a TS proj at work
-- 	if ts_root == nil then
-- 		return print("Unable to find tsconfig")
-- 	end
-- 	vim.cmd("compiler tsc | echo 'Building TypeScript...' | silent make! --noEmit | echo 'TypeScript built.' | copen")
-- end, {})

-- OPTIONS
vim.o.guicursor = vim.o.guicursor .. ",a:Cursor" -- append hl-Cursor to all modes
vim.opt.breakindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "80"
vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.fillchars = { eob = " ", wbr = "▀", vert = "█" } -- see unicode block
vim.opt.ignorecase = true
vim.opt.jumpoptions = "stack"
vim.opt.laststatus = 0
vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.showcmd = false
vim.opt.sidescrolloff = 7
vim.opt.signcolumn = "no"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.undofile = true

vim.diagnostic.config({
	float = { border = "rounded", severity_sort = true },
	severity_sort = true,
	virtual_text = false,
	jump = { float = true }, -- see https://github.com/neovim/neovim/pull/29067
})

function WinBar()
	local icon = vim.bo.modified and "" or ""
	return "%=%#Normal# " .. icon .. " %t %*%="
end
vim.opt.winbar = "%{%v:lua.WinBar()%}"

function Ruler()
	local has_errors = vim.diagnostic.count(0)[vim.diagnostic.severity.ERROR] or 0 > 0
	return has_errors and "%#DiagnosticError#███" or ""
end
vim.opt.rulerformat = "%3(%=%{%v:lua.Ruler()%}%)"
