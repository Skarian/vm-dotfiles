-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  cond = not vim.g.neovide,
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = function(_, opts)
    local utils = require "astrocore"
    return utils.extend_tbl(opts, {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        progress = { enabled = false },
        signature = { enabled = false },
        message = { enabled = true },
      },
      presets = {
        bottom_search = false, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = utils.is_available "inc-rename.nvim", -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
      -- Disables annoying notifications
      routes = {
        {
          filter = {
            event = "notify",
            find = "No information available",
          },
          opts = { skip = true },
          desc = "Skip 'No information available' messages from LSP",
        },
        { filter = { event = "msg_show", find = "%d+L,%s%d+B" }, opts = { skip = true } }, -- skip save notifications
        { filter = { event = "msg_show", find = "^%d+ more lines$" }, opts = { skip = true } }, -- skip paste notifications
        { filter = { event = "msg_show", find = "^%d+ fewer lines$" }, opts = { skip = true } }, -- skip delete notifications
        { filter = { event = "msg_show", find = "^%d+ lines yanked$" }, opts = { skip = true } }, -- skip yank notifications
      },
      -- Disables scrollbar causing clipping issues
      views = {
        hover = {
          scrollbar = false,
          size = { max_width = 70 },
        },
      },
    })
  end,
  init = function() vim.g.lsp_handlers_enabled = false end,
}
