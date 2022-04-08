local lsp_server_installer = require 'nvim-lsp-installer.servers'
local utils = require 'utils'

local M = {}

function M.setup(servers, options)
  for server_name, _ in pairs(servers) do
    -- Install language servers automatically, return on error
    local ok, server = lsp_server_installer.get_server(server_name)

    if ok then
      server:on_ready(function()
        local opts = vim.tbl_deep_extend('force', options, servers[server.name] or {})
        server:setup(opts)
      end)

      if not server:is_installed() then
        utils.info('Installing ' .. server.name)
        server:install()
      end
    else
      utils.error(server)
    end
  end
end

return M
