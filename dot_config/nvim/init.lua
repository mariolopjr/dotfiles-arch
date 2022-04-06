require('plugins')
require('settings')

-- Autocommands
vim.cmd([[
  " Language server commands
  autocmd BufWritePre <buffer> <cmd>EslintFixAll<CR>

  " Chezmoi
  autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path "%"
]])
