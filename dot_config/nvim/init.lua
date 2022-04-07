require('plugins')
require('settings')
require('lsp-config')

-- Autocommands
vim.cmd([[
  " Chezmoi
  autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path "%"
]])
