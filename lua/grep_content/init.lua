-- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local previewers = require "telescope.previewers"
local putils = require "telescope.previewers.utils"
local defaulter = require "telescope.utils".make_default_callable
local sorters = require "telescope.sorters"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local conf = require"telescope.config".values

-- local path = vim.fn.getcwd()..'/'
local path = '/home/craggle/'

local function slurp(p)
    local f = io.open(p, "r")
    if f ~= nil then
        local s = f:read("*a")
        f:close()
        return s
    end
    return nil
end

local prev = defaulter(function(opts)
    return previewers.new_buffer_previewer {
        get_buffer_by_name = function(_, entry)
            return entry.id
        end,

        define_preview = function(self, entry)
            putils.job_maker({"cat", path..entry.value }, self.state.bufnr, {
                value = entry.value,
                bufname = self.state.bufname,
                cwd = opts.cwd,
                -- callback = function(bufnr, content)
                --     vim.api.nvim_buf_call(bufnr, function()
                --         local pattern = read()
                --         vim.fn.matchadd("Visual", pattern)
                --     end)
                -- end
            })
            putils.highlighter(self.state.bufnr, entry.value)
        end,
    }
end, {})

local sort = function(opts)
    opts = opts or {}

    return sorters.Sorter:new {
        scoring_function = function(_, prompt, line, _)
            if line == nil then return -1 end
            local text = slurp(path..line)
            if text == nil then return -1 end
            local contains_string = 1
            local prompt_lower = prompt:lower()
            local line_lower = text:lower()
            if line_lower:find(prompt_lower, 1, true) == nil then contains_string = -1 end
            return contains_string
        end,
    }
end

local map = function(prompt_bufnr, map)
    actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.cmd('e '..path..selection[1])
    end)
    return true
end

local grep_content = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Grep Content",
        finder = finders.new_table { results = vim.fn.readdir(path) },
        sorter = sort(),
        previewer = prev.new(opts),
        attach_mappings = map,
    }):find()
end

return grep_content
