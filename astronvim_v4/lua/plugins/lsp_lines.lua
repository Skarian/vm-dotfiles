if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<Leader>uD"] = {
                function() require("lsp_lines").toggle() end,
                desc = "Toggle virtual diagnostic lines",
              },
            },
          },
        },
      },
      -- {
      --   "AstroNvim/astrocore",
      --   optional = true,
      --   opts = {
      --     diagnostics = {
      --       virtual_text = false,
      --     },
      --   },
      -- },
    },
    opts = {},
  },
}
