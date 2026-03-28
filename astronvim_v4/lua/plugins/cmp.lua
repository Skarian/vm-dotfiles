-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-calc",
    "hrsh7th/cmp-emoji",
    "jc-doyle/cmp-pandoc-references",
    "kdheepak/cmp-latex-symbols",
    "lukas-reineke/cmp-under-comparator",
  },
  opts = function(_, opts)
    local cmp = require "cmp"
    local lspkind = require "lspkind"
    local compare = require "cmp.config.compare"

    local function truncateString(input, length)
      if string.len(input) > length then
        return string.sub(input, 1, length - 3) .. "..."
      else
        return input
      end
    end

    return require("astrocore").extend_tbl(opts, {
      sources = cmp.config.sources {
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        { name = "pandoc_references", priority = 725 },
        { name = "latex_symbols", priority = 700 },
        { name = "emoji", priority = 700 },
        { name = "calc", priority = 650 },
        { name = "path", priority = 500 },
        { name = "buffer", priority = 250 },
      },
      -- From https://github.com/nikbrunner/vin/blob/e65519ee346d4c3b44df7157fce9d67ddbb66b06/lua/vin/plugins/lsp/cmp.lua#L1
      formatting = {
        fields = { "abbr", "kind", "menu" },
        format = lspkind.cmp_format {
          -- mode = "symbol_text",
          mode = "symbol",
          maxwidth = 50,
          ellipses_char = "...",
          before = function(entry, vim_item)
            if entry.completion_item.detail ~= nil and entry.completion_item.detail ~= "" then
              vim_item.menu = truncateString(entry.completion_item.detail, 50)
            else
              vim_item.menu = ({
                nvim_lsp = "[LSP]",
                ultisnips = "[US]",
                luasnip = "[Luasnip]",
                nvim_lua = "[Lua]",
                path = "[Path]",
                buffer = "[Buffer]",
                emoji = "[Emoji]",
                omni = "[Omni]",
              })[entry.source.name]
            end
            return vim_item
          end,
        },
      },
      sorting = {
        comparators = {
          compare.exact,
          compare.score,
          require("cmp-under-comparator").under,
          compare.locality,
          compare.recently_used,
          compare.offset,
          compare.order,
        },
      },
      -- Disabling on 10/25/2024 due to:
      -- https://github.com/hrsh7th/nvim-cmp/issues/1863
      -- https://github.com/hrsh7th/nvim-cmp/issues/1735
      experimental = { ghost_text = false },
    })
  end,
}
