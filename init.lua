vim.o.clipboard = 'unnamedplus'
vim.o.guifont = "Source Code Pro:h7"
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
local set = vim.opt -- set options
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4
set.cmdheight = 0
vim.cmd('set number')
vim.cmd("set list! listchars=tab:\\|\\ ")

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop


-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
	print('Installing lazy.nvim....')
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable', -- latest stable release
		lazypath,
	})
	print('Done.')
end


vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	{ 'williamboman/mason.nvim' },
	{ 'williamboman/mason-lspconfig.nvim' },
	-- LSP Support
	{
		'VonHeikemen/lsp-zero.nvim',
		lazy = true,
		config = false,
	},
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			{ 'hrsh7th/cmp-nvim-lsp',
				{ 'j-hui/fidget.nvim', tag = 'legacy', opts = {} }
			},
		}
	},
	-- Autocompletion
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			{ 'L3MON4D3/LuaSnip' }
		},
	},
	{
		'nvimdev/lspsaga.nvim',
		config = function()
			require('lspsaga').setup({})
		end,
		dependencies = {
			'nvim-treesitter/nvim-treesitter', -- optional
			'nvim-tree/nvim-web-devicons' -- optional
		}
	},
	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		opts = {} -- this is equalent to setup({}) function
	},
	{
		'windwp/nvim-ts-autotag'
	},
	{
		'AstroNvim/astrotheme',
		priority = 1000,
		config = function()
			require("astrotheme").setup {
				palette = "astrodark",
			}
			vim.cmd.colorscheme 'astrotheme'
		end,
	},
	{
		-- Set lualine as statusline
		'nvim-lualine/lualine.nvim',
		-- See `:help lualine.txt`
		opts = {
			options = {
				icons_enabled = true,
				theme = 'auto',
				component_separators = '|',
				section_separators = '',
			},
		},
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require('neo-tree').setup {
				event_handlers = {
					{
						event = "file_opened",
						handler = function()
							require("neo-tree.command").execute({ action = "close" })
						end
					},
				},
				window = {
					position = "float"
				}
			}
		end,
	},
	{
		'ray-x/lsp_signature.nvim',
		opts = {},
		config = function(_, opts) require 'lsp_signature'.setup(opts) end
	},
	{
		"onsails/lspkind.nvim",
		enabled = vim.g.icons_enabled,
	},
	{
		'tomiis4/BufferTabs.nvim',
		dependencies = {
			'nvim-tree/nvim-web-devicons', -- optional
		},
		lazy = false,
		config = function()
			require('buffertabs').setup({
				horizontal = "right",
				icons = true,
				display = "column",
				vertical = "center",
				timeout = 2000
			})
		end
	},
	{
		"Exafunction/codeium.vim",
		config = function()
	
		end
	},
})


local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(_, bufnr)
	-- see :help lsp-zero-keybindings
	-- to learn the available actions
	lsp_zero.default_keymaps({ buffer = bufnr })
end)

require('mason').setup({})
require('mason-lspconfig').setup({
	handlers = {
		lsp_zero.default_setup,
	},
})

require('nvim-ts-autotag').setup()

local cmp = require 'cmp'


local border_opts = {
	border = "rounded",
	winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
}

cmp.setup {
	window = {
		completion = cmp.config.window.bordered(border_opts),
		documentation = cmp.config.window.bordered(border_opts),
	},
	mapping = cmp.mapping.preset.insert {
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<CR>'] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
	},
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, vim_item)
			local kind = require("lspkind").cmp_format({ mode = "symbol", maxwidth = 50, symbol_map = { Codeium = "", } })(
				entry, vim_item)
			local strings = vim.split(kind.kind, "%s", { trimempty = true })
			kind.kind = " " .. (strings[1] or "") .. " "

			return kind
		end,
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "codeium" }
	}

}

require "lsp_signature".setup()



vim.keymap.set('n', '<C-s>', function()
	vim.lsp.buf.format()
	vim.cmd('silent write!')
end, { silent = true })

vim.keymap.set('n', '<C-w>', '<Cmd>bdelete<cr>', { silent = true })


vim.keymap.set({ 'n', 't' }, '<F7>', '<cmd>Lspsaga term_toggle<CR>')
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
vim.keymap.set('n', '<leader>e', '<Cmd>Neotree toggle<cr>', { desc = 'Neotree', silent = true })
vim.keymap.set('n', '<leader>b', '<Cmd>Neotree buffers toggle<cr>', { desc = 'Neotree', silent = true })
vim.keymap.set('n', '<Tab>', '<Cmd>bnext<cr>', { silent = true })
vim.keymap.set('n', '<leader>d', '<Cmd>Lspsaga diagnostic_jump_next<cr>', { silent = true })
vim.keymap.set('n', '<leader>a', '<Cmd>Lspsaga code_action<cr>', { silent = true })
vim.keymap.set('n', '<leader>r', '<Cmd>Lspsaga rename<cr>', { silent = true })
vim.keymap.set('n', '<leader>h', '<Cmd>Lspsaga hover_doc<cr>', { silent = true })

vim.keymap.set('i','<C-Right>','codeium#Accept()',{ silent = true, expr = true, nowait = true })
vim.g.codeium_disable_bindings = 1
