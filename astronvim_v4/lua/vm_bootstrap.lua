local M = {}

local function verify_lazy_plugins()
  local Config = require "lazy.core.config"
  local Git = require "lazy.manage.git"
  local Lock = require "lazy.manage.lock"
  local installed = 0
  local failures = {}

  for _, plugin in pairs(Config.plugins) do
    if plugin.url and not plugin._.is_local then
      installed = installed + 1
      local lock = Lock.get(plugin)
      if not plugin._.installed then
        table.insert(failures, plugin.name .. " (missing)")
      elseif not lock then
        table.insert(failures, plugin.name .. " (not locked)")
      else
        local info = Git.info(plugin.dir)
        if not info or info.commit ~= lock.commit then table.insert(failures, plugin.name .. " (wrong commit)") end
      end
    end
  end

  table.sort(failures)
  if #failures > 0 then error("Lazy plugins failed verification: " .. table.concat(failures, ", ")) end
  print(("Lazy plugins ready: %d"):format(installed))
end

local function add_package(packages, name, version)
  if name then packages[name] = packages[name] or version or false end
end

local function configured_mason_packages()
  local Package = require "mason-core.package"
  local packages = {}

  for _, identifier in ipairs(require("mason-lspconfig.settings").current.ensure_installed) do
    local name, version = Package.Parse(identifier)
    add_package(packages, require("mason-lspconfig.mappings.server").lspconfig_to_package[name], version)
  end

  local null_ls_mappings = require "mason-null-ls.mappings.source"
  for _, identifier in ipairs(require("mason-null-ls.settings").current.ensure_installed) do
    local name, version = Package.Parse(identifier)
    add_package(packages, null_ls_mappings.getPackageFromNullLs(name), version)
  end

  local dap_mappings = require("mason-nvim-dap.mappings.source").nvim_dap_to_package
  for _, identifier in ipairs(require("mason-nvim-dap.settings").current.ensure_installed) do
    local name, version = Package.Parse(identifier)
    add_package(packages, dap_mappings[name], version)
  end

  return packages
end

local function verify_treesitter()
  require("lazy").load { plugins = { "nvim-treesitter" }, wait = true }

  local configured = require("nvim-treesitter.configs").get_ensure_installed_parsers()
  if configured == "all" then configured = require("nvim-treesitter.parsers").available_parsers() end
  local installed = require("nvim-treesitter.info").installed_parsers()
  local missing = vim.tbl_filter(function(parser) return not vim.tbl_contains(installed, parser) end, configured)

  if #missing > 0 then error("Treesitter parsers failed to install: " .. table.concat(missing, ", ")) end
  print(("Treesitter parsers ready: %d"):format(#configured))
end

local function install_mason_packages()
  require("lazy").load {
    plugins = { "mason-lspconfig.nvim", "mason-null-ls.nvim", "mason-nvim-dap.nvim" },
    wait = true,
  }

  local registry = require "mason-registry"
  registry.refresh()

  local packages = configured_mason_packages()
  local handles = {}
  local missing = {}

  for name, version in pairs(packages) do
    local package = registry.get_package(name)
    if not package:is_installed() then handles[name] = package:install { version = version or nil } end
  end

  local completed = vim.wait(900000, function()
    for _, handle in pairs(handles) do
      if not handle:is_closed() then return false end
    end
    return true
  end, 100)

  if not completed then error "Timed out waiting for Mason packages to install" end

  for name in pairs(packages) do
    if not registry.get_package(name):is_installed() then table.insert(missing, name) end
  end
  table.sort(missing)

  if #missing > 0 then error("Mason packages failed to install: " .. table.concat(missing, ", ")) end
  print(("Mason packages ready: %d"):format(vim.tbl_count(packages)))
end

function M.run()
  verify_lazy_plugins()
  verify_treesitter()
  install_mason_packages()
  print "AstroNvim bootstrap complete"
end

function M.command()
  local ok, err = xpcall(M.run, debug.traceback)
  if not ok then
    vim.api.nvim_err_writeln(err)
    vim.cmd.cquit()
  end
  vim.cmd.qa()
end

return M
