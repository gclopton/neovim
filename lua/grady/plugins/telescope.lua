-- telescope.lua
local M = {}

-- Safely import required Telescope modules
local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
  print("Telescope is not installed")
  return M
end

local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
  print("Telescope actions are not available")
  return M
end

-- Additional imports for the custom directory picker
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values

-- Configure telescope with custom mappings
telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
      },
    },
  },
})

-- Load the fzf extension for improved sorting and filtering
telescope.load_extension("fzf")

-- Custom function to change to the selected directory
local function select_directory(prompt_bufnr)
  local selected_dir = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  -- Change the current working directory to the selected directory
  vim.cmd('cd ' .. selected_dir[1])
end

-- Custom picker function for finding and navigating to directories
M.find_directories = function()
  local list_command = { 'fd', '--type', 'd' }

  pickers.new({}, {
    prompt_title = 'Find Directories',
    finder = finders.new_oneshot_job(list_command, {}),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        select_directory(prompt_bufnr)
      end)
      return true
    end,
  }):find()
end

return M
