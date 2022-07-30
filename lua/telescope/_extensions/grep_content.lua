-- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md
return require("telescope").register_extension {
    setup = function(ext_config, config)
        -- access extension config and user config
    end,
    exports = {
        grep_content = require("grep_content")
    },
}
