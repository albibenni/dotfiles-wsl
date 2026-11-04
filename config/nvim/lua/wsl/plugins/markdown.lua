return { "OXY2DEV/markview.nvim", lazy = false, priority = 49, config = function()
    require("markview").setup({ markdown = { headings = require("markview.presets").headings.arrowed }, preview = { icon_provider = "devicons" } })
end }
