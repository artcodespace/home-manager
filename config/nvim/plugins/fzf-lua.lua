local function configure_finder(title, opts)
	return vim.tbl_deep_extend("keep", opts or {}, {
		prompt = title .. "  ",
		winopts = {
			title = "┤ " .. title .. " ├",
			title_pos = "center",
		},
	})
end

require("fzf-lua").setup({
	defaults = {
		file_icons = false,
		git_icons = false,
	},
	keymap = {
		builtin = {
			["<C-d>"] = "preview-page-down",
			["<C-u>"] = "preview-page-up",
		},
		fzf = {
			["ctrl-q"] = "select-all+accept",
		},
	},
	fzf_opts = {
		["--info"] = "default",
		["--pointer"] = "",
		["--marker"] = "",
	},
	fzf_colors = {
		["fg"] = { "fg", { "Comment" } },
		["hl"] = { "fg", { "Normal" } },
		["fg+"] = { "fg", { "PmenuSel" } },
		["bg+"] = { "bg", { "PmenuSel" } },
		["gutter"] = "-1",
		["hl+"] = { "fg", { "PmenuSel" }, "italic", "underline" },
		["query"] = { "fg", { "Cursor" } },
		["info"] = { "fg", { "Comment" } },
		["border"] = { "fg", { "Normal" } },
		["separator"] = { "fg", { "Comment" } },
		["prompt"] = { "fg", { "Normal" } },
		["pointer"] = { "fg", { "PmenuSel" } },
		["marker"] = { "fg", { "Pmenu" } },
		["header"] = { "fg", { "Normal" } },
	},
	files = configure_finder("Finder", { cwd_prompt = false }),
	buffers = configure_finder("Buffers"),
	grep = configure_finder(
		"Ripgrep",
		{ rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e" }
	),
	diagnostics = configure_finder("Diagnostics", {
		severity_limit = "error",
		actions = {
			["ctrl-g"] = function()
				print("TODO hook up severity filter")
			end,
		},
	}),
	lsp = {
		jump_to_single_result = true,
		prompt_postfix = "  ",
		symbols = configure_finder("Symbol"),
	},
	helptags = configure_finder("Help"),
})
