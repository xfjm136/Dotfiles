return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts = opts or {}
      opts.indent = opts.indent or {}
      opts.indent.enable = true
      opts.indent.disable = require("astrocore").list_insert_unique(opts.indent.disable or {}, { "c", "cpp" })
      return opts
    end,
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      opts = opts or {}
      opts.autocmds = opts.autocmds or {}
      opts.autocmds.c_indent_fix = {
        {
          event = { "FileType" },
          pattern = { "c", "cpp" },
          desc = "Use classic cindent for C/C++ to avoid top-level brace indentation issues",
          callback = function()
            local opt = vim.opt_local
            opt.autoindent = true
            opt.smartindent = false
            opt.cindent = true
            opt.indentexpr = ""
            opt.cinoptions = ""
          end,
        },
      }
      return opts
    end,
  },
}
