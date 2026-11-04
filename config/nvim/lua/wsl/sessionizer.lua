local M = {}
function M.projects()
    local output = vim.system({ vim.g.dotfiles_wsl_root .. "/bin/tmux-projects" }, { text = true }):wait()
    if output.code ~= 0 then
        vim.notify("Project discovery failed: " .. (output.stderr or "unknown error"), vim.log.levels.WARN)
        return {}
    end
    return vim.split(output.stdout or "", "\n", { trimempty = true })
end
function M.pick()
    local projects = M.projects()
    if #projects == 0 then vim.notify("Set project roots in ~/.config/dotfiles-wsl-projects", vim.log.levels.WARN); return end
    require("telescope.pickers").new({}, {
        prompt_title = "TMUX Sessionizer", finder = require("telescope.finders").new_table({ results = projects }),
        sorter = require("telescope.config").values.generic_sorter({}),
        attach_mappings = function(buffer)
            require("telescope.actions").select_default:replace(function()
                local entry = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(buffer)
                if not entry or not entry.value then return end
                local command = { vim.g.dotfiles_wsl_root .. "/bin/tmux-sessionizer", entry.value }
                if vim.env.TMUX then vim.fn.jobstart(command, { detach = true });
                else vim.cmd.tabnew(); vim.fn.jobstart(command, { term = true }); vim.cmd.startinsert(); end
            end)
            return true
        end,
    }):find()
end
return M
