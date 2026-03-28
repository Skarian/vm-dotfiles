-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts) -- override the options using lazy.nvim
    local actions = require "telescope.actions"
    opts.pickers = {
      -- Sorts buffer picker by most recent, removes current buffer and adds delete keymap
      buffers = {
        sort_mru = true,
        ignore_current_buffer = true,
        mappings = {
          n = {
            ["d"] = actions.delete_buffer,
          },
        },
      },
    }
  end,
}
