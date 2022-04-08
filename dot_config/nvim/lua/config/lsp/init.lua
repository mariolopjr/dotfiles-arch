local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local M = {}

local servers = {
  gopls = {},
  html = {},
  jsonls = {},
  sumneko_lua = {},
  tsserver = {},
}

local function on_attach(client, bufnr)
  -- Enable omifunc completion <C-X><C-O>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Use LSP as the handler for formatexpr.
  vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

  -- Configure key mappings
  require('config.lsp.keymaps').setup(client, bufnr)
end

local opts = {
  on_attach = on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 150, -- default in neovim 0.7+
  },
}

function M.setup()
  require('config.lsp.installer').setup(servers, opts)
end

return M
