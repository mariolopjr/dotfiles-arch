local api = vim.api
local g = vim.g
local o = vim.o
local opt = vim.opt

-- Remap leader and local leader to <Space>
api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
g.mapleader = ' '
g.maplocalleader = ' '

opt.termguicolors = true
opt.hlsearch = true
opt.number = true
opt.mouse = 'a'
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 250
opt.signcolumn = 'yes'
opt.timeoutlen = 300

-- Sidebar
o.number = true
o.numberwidth = 3
o.signcolumn = 'yes'
o.modelines = 0
o.showcmd = true

-- Search
opt.path:remove '/usr/include'
opt.path:append '**'
opt.wildignore:append '**/node_modules/*'
opt.wildignore:append '**/.git/*'
opt.wildignore:append '**/build/*'

-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

