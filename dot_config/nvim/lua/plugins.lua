local M = {}

function M.setup()
  -- First time installing packer
  local packer_bootstrap = false

  -- Packer configuration
  local conf = {
    profile = {
      enable = true,
      threshold = 0, -- the amount in ms that a plugins load time must be over for it to be included in the profile
    },

    display = {
      open_fn = function()
        return require('packer.util').float { border = 'rounded' }
      end,
    },
  }

  -- Check if packer is installed
  -- Run PackerCompile if there are changes to this file
  local function packer_init()
    local fn = vim.fn
    local install_path = fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
      packer_bootstrap = fn.system {
        'git',
        'clone',
        '--depth',
        '1',
        'https://github.com/wbthomason/packer.nvim',
        install_path,
      }
      vim.cmd [[packadd packer.nvim]]
    end
    vim.cmd 'autocmd BufWritePost plugins.lua source <afile> | PackerCompile'
  end

  -- Plugins
  local function plugins(use)
    use 'wbthomason/packer.nvim'

    -- Theme
    use {
      'shaunsingh/nord.nvim',
      config = function ()
        vim.g.nord_italic = true
        vim.cmd 'colorscheme nord'
      end,
    }

    -- Utilities
    use {
      "rcarriga/nvim-notify",
      event = "VimEnter",
      config = function()
        vim.notify = require "notify"
      end,
    }

    use {
      'goolord/alpha-nvim',
      config = function()
        require('alpha').setup(require'alpha.themes.dashboard'.config)
      end,
    }

    use {
      'folke/which-key.nvim',
      event = 'VimEnter',
      config = function()
        require('config.whichkey').setup()
      end,
    }

    use { 'nvim-lua/plenary.nvim', module = 'plenary' }

    use {
      'TimUntersberger/neogit',
      cmd = 'Neogit',
      config = function()
        require('config.neogit').setup()
      end,
    }

    use { 'lewis6991/gitsigns.nvim',
      requires = { 'nvim-lua/plenary.nvim' },
      config = function()
        require('gitsigns').setup({
          current_line_blame = false,
        })
      end,
    }

    use {
      'kyazdani42/nvim-tree.lua',
      requires = { 'kyazdani42/nvim-web-devicons' },
      config = function()
        require('config.nvimtree').setup()
      end,
    }

    use 'rhysd/git-messenger.vim'

    -- UI
    use {
      'nvim-lualine/lualine.nvim',
      event = "VimEnter",
      config = function()
        require('config.lualine').setup()
      end,
      requires = { 'kyazdani42/nvim-web-devicons' },
    }

    use {
      'stevearc/dressing.nvim',
      event = 'BufEnter',
      config = function()
        require('dressing').setup ({
          select = {
            backend = { 'telescope', 'fzf', 'builtin' },
          },
        })
      end,
      disable = true,
    }

    -- Search
    use {
      'nvim-telescope/telescope.nvim',
      opt = true,
      config = function ()
        require('config.telescope').setup()
      end,
      cmd = { 'Telescope' },
      module = 'telescope',
      keys = { '<leader>f', '<leader>p' },
      wants = {
        'plenary.nvim',
        'popup.nvim',
        'telescope-fzf-native.nvim',
        'telescope-project.nvim',
        'telescope-repo.nvim',
        'telescope-file-browser.nvim',
        'project.nvim',
      },
      requires = {
        "nvim-lua/popup.nvim",
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
        "nvim-telescope/telescope-project.nvim",
        "cljoly/telescope-repo.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
        {
          "ahmedkhalf/project.nvim",
          config = function()
            require("project_nvim").setup {}
          end,
        },
      },
    }
    use 'tpope/vim-eunuch'
    use 'tpope/vim-surround'

    -- Dev
    use {
      'neovim/nvim-lspconfig',
      opt = true,
      event = 'BufReadPre',
      wants = { 'nvim-lsp-installer' },
      config = function ()
        require('config.lsp').setup()
      end,
      requires = { 'williamboman/nvim-lsp-installer' },
    }

    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = function()
        require('config.treesitter').setup()
      end,
    }

    use {
      'SmiteshP/nvim-gps',
      requires = 'nvim-treesitter/nvim-treesitter',
      module = 'nvim-gps',
      config = function()
        require('nvim-gps').setup()
      end,
    }

    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'onsails/lspkind-nvim'
    use 'saadparwaiz1/cmp_luasnip'
    use 'L3MON4D3/LuaSnip'

    use 'mfussenegger/nvim-dap'
    use 'rcarriga/nvim-dap-ui'
    use 'theHamsta/nvim-dap-virtual-text'
    use 'ray-x/guihua.lua'

    use 'ray-x/go.nvim'

    use {
      'numToStr/Comment.nvim',
      keys = { 'gc', 'gcc', 'gbc' },
      config = function()
          require('Comment').setup()
      end,
    }

    use {
      'lukas-reineke/indent-blankline.nvim',
      event = 'BufReadPre',
      config = function()
        require('config.indentblankline').setup()
      end,
    }

    -- Bootstrap Neovim
    if packer_bootstrap then
      print 'Restart Neovim required after installation!'
      require('packer').sync()
    end
  end

  packer_init()

  local packer = require 'packer'
  packer.init(conf)
  packer.startup(plugins)
end

return M
