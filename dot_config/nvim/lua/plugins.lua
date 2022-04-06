local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- utilities
  use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }
  require('neogit').setup()

  use { 'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup({
        current_line_blame = false
      })
    end
  }

  use {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function() require'nvim-tree'.setup {} end
  }

  use 'rhysd/git-messenger.vim'

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  require('lualine').setup({
    options = {
      theme = 'material',
    },
  })

  use 'marko-cerovac/material.nvim'
  require('material').set({
    lualine_style = 'default',
    italics = {
      keywords = true,
      functions = true,
    },
  })

  -- search
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/popup.nvim', 'nvim-lua/plenary.nvim' } }
  use 'tpope/vim-eunuch'
  use 'tpope/vim-surround'

  -- dev
  use 'neovim/nvim-lspconfig'
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  require'nvim-treesitter.configs'.setup {
    highlight = {
      enable = true,
      disable = {}
    }
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end)
