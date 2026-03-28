-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "goolord/alpha-nvim",
  opts = function(_, opts) -- override the options using lazy.nvim
    opts.section.header.val = { -- change the header section value
      "███████╗██╗  ██╗ █████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
      "██╔════╝██║ ██╔╝██╔══██╗██╔══██╗██║   ██║██║████╗ ████║",
      "███████╗█████╔╝ ███████║██████╔╝██║   ██║██║██╔████╔██║",
      "╚════██║██╔═██╗ ██╔══██║██╔══██╗╚██╗ ██╔╝██║██║╚██╔╝██║",
      "███████║██║  ██╗██║  ██║██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║",
      "╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
    }
  end,
}
