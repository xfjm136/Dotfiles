-- lua with lazy.nvim
return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = {
        "nhattVim/alpha-ascii.nvim",
        opts = { header = "cat_girl" },
    },
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")
        local function picker(name)
            return ("<cmd>lua require('snacks').picker.%s()<CR>"):format(name)
        end

        dashboard.section.buttons.val = {
            dashboard.button("SPC f f", "  Find File  ", picker "files"),
            dashboard.button("SPC f o", "  Recent File  ", picker "recent"),
            dashboard.button("SPC f w", "  Find Word  ", picker "grep"),
            dashboard.button("SPC f '", "  Bookmarks  ", picker "marks"),
            dashboard.button("SPC f t", "  Themes  ", picker "colorschemes"),
            dashboard.button(
                "SPC f a",
                "  Config Files",
                "<cmd>lua require('snacks').picker.files({ dirs = { vim.fn.stdpath('config') } })<CR>"
            ),
            dashboard.button("SPC c i", "  Change header image", ":AlphaAsciiNext<CR>"),
        }

        vim.api.nvim_create_autocmd("User", {
            once = true,
            pattern = "LazyVimStarted",
            callback = function()
                local stats = require("lazy").stats()
                local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                dashboard.section.footer.val = {
                    " ",
                    " Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins  in " .. ms .. " ms ",
                }
                pcall(vim.cmd.AlphaRedraw)
            end,
        })

        alpha.setup(dashboard.opts)
    end,
}
