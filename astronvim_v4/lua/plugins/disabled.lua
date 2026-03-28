if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
--
-- Example of how to turn off plugins from spec
-- https://docs.astronvim.com/configuration/customizing_plugins/#disabling-plugins

---@type LazySpec
return {
  { "windwp/nvim-ts-autotag", enabled = false },
}
