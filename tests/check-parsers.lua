-- Missing parsers return nil without throwing; a successful pcall is insufficient.
local original_vim = vim
local previous = package.loaded['wsl.parsers']
local installed = { present = true }
local calls = {}
package.loaded['wsl.parsers'] = { 'present', 'missing' }
vim = {
    treesitter = { language = { add = function(name)
        if installed[name] then return true end
        return nil, 'No parser'
    end } },
    cmd = function(command)
        calls[#calls + 1] = command
        if command == 'TSInstallSync missing' then installed.missing = true end
        if command == 'cquit 1' then error('Parser installation failed') end
    end,
}
local ok, err = pcall(function()
    dofile(arg[1])
    assert(installed.missing and calls[1] == 'TSInstallSync missing')
    calls = {}
    dofile(arg[1])
    assert(#calls == 1 and calls[1] == 'qa!', 'Already installed parsers should not prompt/reinstall')
end)
vim = original_vim
package.loaded['wsl.parsers'] = previous
assert(ok, err)
print('Parser installation handles nil results and skips existing parsers.')
