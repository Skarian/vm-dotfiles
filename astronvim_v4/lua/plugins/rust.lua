local pack = {
  { import = "astrocommunity.pack.toml" },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "rust" })
      end
    end,
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@param opts AstroLSPOpts
    opts = {
      handlers = { rust_analyzer = false }, -- disable setup of `rust_analyzer`
      ---@diagnostic disable: missing-fields
      config = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              check = {
                command = "clippy",
                -- extraArgs = {
                --   "--no-deps",
                -- },
              },
              cargo = {
                extraEnv = { CARGO_PROFILE_RUST_ANALYZER_INHERITS = "dev" },
                extraArgs = { "--profile", "rust-analyzer" },
              },
            },
          },
        },
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "codelldb" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "codelldb" })
    end,
  },
  -- "Saecki/crates.nvim",
  -- lazy = true,
  -- dependencies = {
  --   "AstroNvim/astrocore",
  --   opts = {
  --     autocmds = {
  --       CmpSourceCargo = {
  --         {
  --           event = "BufRead",
  --           desc = "Load crates.nvim into Cargo buffers",
  --           pattern = "Cargo.toml",
  --           callback = function()
  --             require("cmp").setup.buffer { sources = { { name = "crates" } } }
  --             require "crates"
  --           end,
  --         },
  --       },
  --     },
  --   },
  -- },
  -- opts = {
  --   popup = {
  --     autofocus = true,
  --   },
  --   completion = {
  --     cmp = { enabled = true },
  --     crates = {
  --       enabled = true,
  --     },
  --   },
  --   null_ls = {
  --     enabled = true,
  --     name = "crates.nvim",
  --   },
  --   on_attach = function(bufnr)
  --     local crates = require "crates"
  --     local utils = require "astrocore"
  --     utils.set_mappings({
  --       n = {
  --         ["<leader>r"] = { name = "+ Crates" },
  --         ["<leader>rt"] = { crates.toggle, desc = "Toggle crates" },
  --         ["<leader>rr"] = { crates.reload, desc = "Reload crates" },
  --         ["<leader>rv"] = { crates.show_versions_popup, desc = "Show crate versions popup" },
  --         ["<leader>rf"] = { crates.show_features_popup, desc = "Show crate features popup" },
  --         ["<leader>rd"] = { crates.show_dependencies_popup, desc = "Show crate dependencies popup" },
  --         ["<leader>ru"] = { crates.update_crate, desc = "Update crate" },
  --         ["<leader>ra"] = { crates.update_all_crates, desc = "Update all crates" },
  --         ["<leader>rU"] = { crates.upgrade_crate, desc = "Upgrade crate" },
  --         ["<leader>rA"] = { crates.upgrade_all_crates, desc = "Upgrade all crates" },
  --         ["<leader>rH"] = { crates.open_homepage, desc = "Open crate homepage" },
  --         ["<leader>rR"] = { crates.open_repository, desc = "Open crate repository" },
  --         ["<leader>rD"] = { crates.open_documentation, desc = "Open crate documentation" },
  --         ["<leader>rC"] = { crates.open_crates_io, desc = "Open crates.io" },
  --       },
  --     }, { buffer = bufnr })
  --   end,
  -- },
  {
    "Saecki/crates.nvim",
    lazy = true,
    dependencies = {
      "AstroNvim/astrocore",
      opts = {
        autocmds = {
          CmpSourceCargo = {
            {
              event = "BufRead",
              desc = "Load crates.nvim into Cargo buffers",
              pattern = "Cargo.toml",
              callback = function()
                require("cmp").setup.buffer { sources = { { name = "crates" } } }
                require "crates"
              end,
            },
          },
        },
      },
    },
    opts = {
      popup = {
        autofocus = true,
      },
      completion = {
        cmp = { enabled = true },
        crates = {
          enabled = true,
        },
      },
      null_ls = {
        enabled = true,
        name = "crates.nvim",
      },
      on_attach = function(bufnr)
        local crates = require "crates"
        local utils = require "astrocore"
        utils.set_mappings({
          n = {
            ["<leader>r"] = { name = "+ Crates" },
            ["<leader>rt"] = { crates.toggle, desc = "Toggle crates" },
            ["<leader>rr"] = { crates.reload, desc = "Reload crates" },
            ["<leader>rv"] = { crates.show_versions_popup, desc = "Show crate versions popup" },
            ["<leader>rf"] = { crates.show_features_popup, desc = "Show crate features popup" },
            ["<leader>rd"] = { crates.show_dependencies_popup, desc = "Show crate dependencies popup" },
            ["<leader>ru"] = { crates.update_crate, desc = "Update crate" },
            ["<leader>ra"] = { crates.update_all_crates, desc = "Update all crates" },
            ["<leader>rU"] = { crates.upgrade_crate, desc = "Upgrade crate" },
            ["<leader>rA"] = { crates.upgrade_all_crates, desc = "Upgrade all crates" },
            ["<leader>rH"] = { crates.open_homepage, desc = "Open crate homepage" },
            ["<leader>rR"] = { crates.open_repository, desc = "Open crate repository" },
            ["<leader>rD"] = { crates.open_documentation, desc = "Open crate documentation" },
            ["<leader>rC"] = { crates.open_crates_io, desc = "Open crates.io" },
          },
        }, { buffer = bufnr })
      end,
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      local rustaceanvim_avail, rustaceanvim = pcall(require, "rustaceanvim.neotest")
      if rustaceanvim_avail then table.insert(opts.adapters, rustaceanvim) end
    end,
  },
}

if vim.fn.has "nvim-0.10" == 1 then
  -- Rustaceanvim v5 supports neovim v0.10+
  table.insert(pack, {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = "rust",
    specs = {
      {
        "AstroNvim/astrolsp",
        optional = true,
        ---@type AstroLSPOpts
        opts = {
          handlers = { rust_analyzer = false }, -- disable setup of `rust_analyzer`
        },
      },
    },
    opts = function()
      local adapter
      local success, package = pcall(function() return require("mason-registry").get_package "codelldb" end)
      local cfg = require "rustaceanvim.config"
      if success then
        local package_path = package:get_install_path()
        local codelldb_path = package_path .. "/codelldb"
        local liblldb_path = package_path .. "/extension/lldb/lib/liblldb"
        local this_os = vim.loop.os_uname().sysname

        -- The path in windows is different
        if this_os:find "Windows" then
          codelldb_path = package_path .. "\\extension\\adapter\\codelldb.exe"
          liblldb_path = package_path .. "\\extension\\lldb\\bin\\liblldb.dll"
        else
          -- The liblldb extension is .so for linux and .dylib for macOS
          liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
        end
        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
      else
        adapter = cfg.get_codelldb_adapter()
      end

      local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
      local astrolsp_opts = (astrolsp_avail and astrolsp.lsp_opts "rust_analyzer") or {}
      local server = {
        ---@type table | (fun(project_root:string|nil, default_settings: table|nil):table) -- The rust-analyzer settings or a function that creates them.
        settings = function(project_root, default_settings)
          local astrolsp_settings = astrolsp_opts.settings or {}

          local merge_table = require("astrocore").extend_tbl(default_settings or {}, astrolsp_settings)
          local ra = require "rustaceanvim.config.server"
          -- load_rust_analyzer_settings merges any found settings with the passed in default settings table and then returns that table
          return ra.load_rust_analyzer_settings(project_root, {
            settings_file_pattern = "rust-analyzer.json",
            default_settings = merge_table,
          })
        end,
      }
      local final_server = require("astrocore").extend_tbl(astrolsp_opts, server)
      return {
        server = final_server,
        dap = { adapter = adapter },
        tools = {
          enable_clippy = false,
          float_win_config = {
            border = "rounded",
          },
        },
      }
    end,
    config = function(_, opts) vim.g.rustaceanvim = require("astrocore").extend_tbl(opts, vim.g.rustaceanvim) end,
  })
else
  -- TODO: Remove this with AstroNvim v5 when dropping Neovim v0.9 support
  -- Rustaceanvim v4 is the last version that supports neovim v0.9
  -- This is simply a copy/paste of the v4 configuration to be left alone just in case
  -- the setup gets breaking changes and diverges.
  table.insert(pack, {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = "rust",
    specs = {
      {
        "AstroNvim/astrolsp",
        optional = true,
        ---@type AstroLSPOpts
        opts = {
          handlers = { rust_analyzer = false }, -- disable setup of `rust_analyzer`
        },
      },
    },
    opts = function()
      local adapter
      local success, package = pcall(function() return require("mason-registry").get_package "codelldb" end)
      local cfg = require "rustaceanvim.config"
      if success then
        local package_path = package:get_install_path()
        local codelldb_path = package_path .. "/codelldb"
        local liblldb_path = package_path .. "/extension/lldb/lib/liblldb"
        local this_os = vim.loop.os_uname().sysname

        -- The path in windows is different
        if this_os:find "Windows" then
          codelldb_path = package_path .. "\\extension\\adapter\\codelldb.exe"
          liblldb_path = package_path .. "\\extension\\lldb\\bin\\liblldb.dll"
        else
          -- The liblldb extension is .so for linux and .dylib for macOS
          liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
        end
        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
      else
        adapter = cfg.get_codelldb_adapter()
      end

      local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
      local astrolsp_opts = (astrolsp_avail and astrolsp.lsp_opts "rust_analyzer") or {}
      local server = {
        ---@type table | (fun(project_root:string|nil, default_settings: table|nil):table) -- The rust-analyzer settings or a function that creates them.
        settings = function(project_root, default_settings)
          local astrolsp_settings = astrolsp_opts.settings or {}

          local merge_table = require("astrocore").extend_tbl(default_settings or {}, astrolsp_settings)
          local ra = require "rustaceanvim.config.server"
          -- load_rust_analyzer_settings merges any found settings with the passed in default settings table and then returns that table
          return ra.load_rust_analyzer_settings(project_root, {
            settings_file_pattern = "rust-analyzer.json",
            default_settings = merge_table,
          })
        end,
      }
      local final_server = require("astrocore").extend_tbl(astrolsp_opts, server)
      return { server = final_server, dap = { adapter = adapter }, tools = { enable_clippy = false } }
    end,
    config = function(_, opts) vim.g.rustaceanvim = require("astrocore").extend_tbl(opts, vim.g.rustaceanvim) end,
  })
end

return pack
