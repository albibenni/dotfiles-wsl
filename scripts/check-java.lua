local ok, err = xpcall(function()
    local root = vim.fn.tempname()
    vim.fn.mkdir(root .. "/src/sample", "p")
    vim.fn.mkdir(root .. "/.settings", "p")
    vim.fn.writefile({ '<?xml version="1.0"?><projectDescription><name>wsl-java-test</name><comment></comment><projects></projects><buildSpec><buildCommand><name>org.eclipse.jdt.core.javabuilder</name><arguments></arguments></buildCommand></buildSpec><natures><nature>org.eclipse.jdt.core.javanature</nature></natures></projectDescription>' }, root .. "/.project")
    vim.fn.writefile({ '<?xml version="1.0"?><classpath><classpathentry kind="src" path="src"/><classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-25"/><classpathentry kind="output" path="bin"/></classpath>' }, root .. "/.classpath")
    vim.fn.writefile({ 'eclipse.preferences.version=1', 'org.eclipse.jdt.core.compiler.compliance=25', 'org.eclipse.jdt.core.compiler.source=25', 'org.eclipse.jdt.core.compiler.codegen.targetPlatform=25' }, root .. "/.settings/org.eclipse.jdt.core.prefs")
    vim.fn.writefile({ 'package sample;', 'public class Main {', '  public static void main(String[] args) {', '    int value = "wrong";', '  }', '}' }, root .. "/src/sample/Main.java")
    vim.cmd.cd(root)
    vim.cmd.edit(root .. "/src/sample/Main.java")
    local buffer = vim.api.nvim_get_current_buf()
    assert(vim.wait(90000, function()
        local clients = vim.lsp.get_clients({ bufnr = buffer, name = "jdtls" })
        return #clients == 1 and clients[1].initialized
    end, 100), "JDTLS did not initialize")
    assert(vim.wait(90000, function()
        for _, diagnostic in ipairs(vim.diagnostic.get(buffer)) do
            if diagnostic.severity == vim.diagnostic.severity.ERROR and diagnostic.message:find("String") and diagnostic.message:find("int") then return true end
        end
        return false
    end, 100), "JDTLS did not report the deliberate type mismatch: " .. vim.inspect(vim.diagnostic.get(buffer)))
    assert(vim.fn.maparg("<leader>co", "n", false, true).desc == "Java: organize imports")
    local first = require("wsl.java").paths("/tmp/first/project")
    local second = require("wsl.java").paths("/tmp/second/project")
    assert(first ~= second, "Same-named Java projects share a workspace")
    assert(vim.treesitter.get_parser(buffer):parse()[1], "Java parser did not parse the file")
    assert(vim.fn.exists(":JdtCompile") == 2, "JDTLS extensions not registered")
end, debug.traceback)
for _, client in ipairs(vim.lsp.get_clients()) do client:stop(true) end
if not ok then io.stderr:write(tostring(err) .. "\n"); vim.cmd("cquit 1") end
print("JDTLS initialized; Java type diagnostic, refactoring key, parser and workspace isolation passed.")
vim.cmd("qa!")
