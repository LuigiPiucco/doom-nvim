-- Add ~/.local/share to runtimepath early, such that
-- neovim autoloads plugin/packer_compiled.lua along with vimscript,
-- before we start using the plugins it lazy-loads.
vim.opt.runtimepath:append(vim.fn.stdpath("data"))

-- From here on, we have a hidden global `_doom` that holds state the user
-- shouldn't mess with.
_G._doom = {}

-- From here on, we have a global `doom` with config.
require("doom.core.config"):load()
-- Load Doom core and UI related stuff (colorscheme, background).
local utils = require("doom.utils")
utils.load_modules("doom", { "core" })

-- Defer and schedule loading of modules until the Neovim API functions are
-- safe to call to avoid weird errors with plugins stuff.
vim.defer_fn(function()
  -- Load Doom modules.
  utils.load_modules("doom", { "modules" })
end, 0)
