local M = {}
function M.projects()
    local home = vim.env.HOME
    local roots = { home .. "/projects", home .. "/dotfiles-wsl" }
    local file = (vim.env.XDG_CONFIG_HOME or (home .. "/.config")) .. "/dotfiles-wsl-projects"
    if vim.fn.filereadable(file) == 1 then
        roots = {}
        for _, line in ipairs(vim.fn.readfile(file)) do
            if line ~= "" and not line:match("^#") then
                if line:sub(1, 1) == "~" then line = home .. line:sub(2) end
                if line:sub(1, 1) == "/" then roots[#roots + 1] = line end
            end
        end
    end
    local seen, result = {}, {}
    for _, path in ipairs(roots) do
        if vim.fn.isdirectory(path) == 1 then
            local output = vim.system({ "find", path, "-maxdepth", "2", "-type", "d", "-not", "-path", "*/.git*", "-not", "-path", "*/node_modules*" }, { text = true }):wait()
            for line in (output.stdout or ""):gmatch("[^\n]+") do
                if not seen[line] then result[#result + 1] = line; seen[line] = true end
            end
        end
    end
    table.sort(result)
    return result
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
