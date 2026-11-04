local M = {}
function M.paths(root)
    root = vim.uv.fs_realpath(root) or root
    local name = vim.fn.fnamemodify(root, ":t"):gsub("[^%w_-]", "_")
    local key = name .. "-" .. vim.fn.sha256(root):sub(1, 12)
    return vim.fn.stdpath("state") .. "/jdtls/" .. key, vim.fn.stdpath("cache") .. "/jdtls/" .. key
end
function M.runtimes()
    local result, seen = {}, {}
    local selected = vim.env.JAVA_HOME and vim.uv.fs_realpath(vim.env.JAVA_HOME)
    local homes = {}
    if selected then homes[#homes + 1] = selected end
    local data = vim.env.MISE_DATA_DIR or ((vim.env.XDG_DATA_HOME or (vim.env.HOME .. "/.local/share")) .. "/mise")
    for _, release in ipairs(vim.fn.glob(data .. "/installs/java/*/release", false, true)) do
        homes[#homes + 1] = vim.fs.dirname(release)
    end
    for _, home in ipairs(homes) do
        home = vim.uv.fs_realpath(home) or home
        if vim.fn.filereadable(home .. "/release") == 1 and vim.fn.executable(home .. "/bin/java") == 1 then
            for _, line in ipairs(vim.fn.readfile(home .. "/release")) do
                local version = line:match('^JAVA_VERSION="([^"]+)')
                if version then
                    local major = tonumber(version:match("^1%.(%d+)") or version:match("^(%d+)"))
                    if major and not seen[major] then
                        result[#result + 1] = { name = major <= 8 and ("JavaSE-1." .. major) or ("JavaSE-" .. major), path = home, default = home == selected }
                        seen[major] = true
                    end
                end
            end
        end
    end
    return result
end
function M.setup()
    local root = vim.fs.root(0, { "mvnw", "gradlew", "pom.xml", "settings.gradle", "settings.gradle.kts", "build.gradle", "build.gradle.kts", ".project", ".git" })
        or vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    if not root or root == "" then return end
    local workspace, config = M.paths(root)
    vim.fn.mkdir(workspace, "p")
    local jdtls = require("jdtls")
    jdtls.start_or_attach({
        name = "jdtls", root_dir = root,
        cmd = { vim.g.dotfiles_wsl_root .. "/bin/jdtls", "-data", workspace },
        cmd_env = { JDTLS_CONFIG_DIR = config },
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        settings = { java = {
            signatureHelp = { enabled = true }, contentProvider = { preferred = "fernflower" },
            configuration = { updateBuildConfiguration = "interactive", runtimes = M.runtimes() },
            completion = { favoriteStaticMembers = {
                "org.hamcrest.MatcherAssert.assertThat", "org.hamcrest.Matchers.*", "org.hamcrest.CoreMatchers.*",
                "org.junit.jupiter.api.Assertions.*", "java.util.Objects.requireNonNull", "java.util.Objects.requireNonNullElse", "org.mockito.Mockito.*",
            }, filteredTypes = { "com.sun.*", "io.micrometer.shaded.*", "java.awt.*", "jdk.*", "sun.*" } },
        } },
        init_options = { bundles = {} },
        on_attach = function(_, buffer)
            local function map(mode, key, callback, description)
                vim.keymap.set(mode, key, callback, { buffer = buffer, desc = description })
            end
            map("n", "<leader>co", jdtls.organize_imports, "Java: organize imports")
            map("n", "<leader>jv", jdtls.extract_variable, "Java: extract variable")
            map("n", "<leader>jc", jdtls.extract_constant, "Java: extract constant")
            map("x", "<leader>jm", function() jdtls.extract_method(true) end, "Java: extract method")
        end,
    })
end
return M
