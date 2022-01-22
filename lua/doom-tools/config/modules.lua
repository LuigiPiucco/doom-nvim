-- Returns all modules, such that everything is enabled.

local uv = vim.loop

local function scan_dir(dir)
  local dirs = vim.fn.readdir(dir)
  return dirs
end

-- This will be copied to the root of the repo in CI, so we pretend that's
-- out working directory.
local folder = "lua/doom/modules"
local modules = scan_dir(folder)
-- Remove the README.md and init.lua from the list.
for i, mod in ipairs(modules) do
  if vim.tbl_contains({ "README.md", "init.lua" }, mod) then
    table.remove(modules, i)
  end
end

return modules
