return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if vim.env.VM_DOTFILES_NVIM_BOOTSTRAP == "plugins" then
        opts.ensure_installed = {}
      elseif vim.env.VM_DOTFILES_NVIM_BOOTSTRAP == "assets" then
        opts.sync_install = true
      end
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    optional = true,
    build = "cd app && yarn install",
  },
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      if vim.env.VM_DOTFILES_NVIM_BOOTSTRAP == "plugins" then opts.ensure_installed = {} end
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      if vim.env.VM_DOTFILES_NVIM_BOOTSTRAP == "plugins" then opts.ensure_installed = {} end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      if vim.env.VM_DOTFILES_NVIM_BOOTSTRAP == "plugins" then opts.ensure_installed = {} end
    end,
  },
}
