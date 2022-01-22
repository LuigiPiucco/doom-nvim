---## Core module

---Add the basic functionality expected of any neovim configuration. It
---includes treesitter's umbrella, keybindings, utilities required by many
---plugins (such as plenary.nvim) and package management via packer.nvim. This
---is not removable and need not be listed is your config, we add it
---automatically.

local core = {}

---### Configuration and defaults

---Defaults added to `doom.core`.
---@class core.defaults
---Settings passed verbatim to nvim-mapper's setup.
---See their README for details.
---@field mapper table
---Settings passed to nvim-treesitter's setup.
---See their README for details.
---
---The `autopairs.enable` key is always set to whether the autopairs module
---is enabled.
---@field treesitter table
core.defaults = {
  nest_integrations = {},
  mapper = {},
  treesitter = {
    highlight = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
    indent = {
      enable = true,
    },
    playground = {
      enable = true,
    },
    context_commentstring = {
      enable = true,
    },
    autotag = {
      enable = true,
      filetypes = {
        "html",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "svelte",
        "vue",
        "markdown",
      },
    },
  },
}

core.packer_config = {}
core.packer_config["nest.nvim"] = function()
  local utils = require("doom.utils")
  local is_plugin_disabled = utils.is_plugin_disabled

  local nest_package = require("nest")

  nest_package.enable(require("nest.integrations.mapper"))
  if not is_plugin_disabled("whichkey") then
    local whichkey_integration = require("nest.integrations.whichkey")
    nest_package.enable(whichkey_integration)
  end
  if vim.g.doom_write_binds then
    local keybind_doc_integration = require("doom-tools.docs.keybind_doc_integration")
    nest_package.enable(keybind_doc_integration)
    keybind_doc_integration.set_table_fields({
      { key = "lhs", name = "Keybind" },
      { key = "name", name = "Name" },
    })
    nest_package.traverse(doom.binds, { keybind_doc_integration })
  end
  for _,integration in ipairs(doom.core.nest_integrations) do
    nest_package.enable(integration)
  end

  nest_package.applyKeymaps(doom.binds)
end
core.packer_config["nvim-mapper"] = function()
  require("nvim-mapper").setup(doom.core.mapper)
end
core.packer_config["nvim-treesitter"] = function()
  local is_plugin_disabled = require("doom.utils").is_plugin_disabled
  require("nvim-treesitter.configs").setup(vim.tbl_deep_extend("force", doom.core.treesitter, {
    autopairs = {
      enable = not is_plugin_disabled("autopairs"),
    },
  }))

  --  Check if user is using clang and notify that it has poor compatibility with treesitter
  --  WARN: 19/11/2021 | issues: #222, #246 clang compatibility could improve in future
  vim.defer_fn(function()
    local log = require("doom.utils.logging")
    local utils = require("doom.utils")
    -- Matches logic from nvim-treesitter
    local compiler = utils.find_executable_in_path({
      vim.fn.getenv("CC"),
      "cc",
      "gcc",
      "clang",
      "cl",
      "zig",
    })
    local version = vim.fn.systemlist(compiler .. (compiler == "cl" and "" or " --version"))[1]

    if version:match("clang") then
      log.warn(
        "doom-treesitter:  clang has poor compatibility compiling treesitter parsers.  We recommend using gcc, see issue #246 for details.  (https://github.com/NTBBloodbath/doom-nvim/issues/246)"
      )
    end
  end, 1000)
end

return core
