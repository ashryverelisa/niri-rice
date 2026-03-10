return {
    {
        "nvim-treesitter/nvim-treesitter", 
        branch = 'master', 
        build = ":TSUpdate",
        config = function()
            local config = require("nvim-treesitter.configs")
            config.setup({
                auto_install = true,
                hightlight = { enalbe = true },
                indent = { enalbe = true }
            })
        end
    }
}