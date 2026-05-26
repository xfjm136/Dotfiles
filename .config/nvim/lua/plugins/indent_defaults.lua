return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      opts = opts or {}
      opts.options = opts.options or {}
      opts.options.opt = opts.options.opt or {}
      opts.options.opt.copyindent = true
      opts.options.opt.preserveindent = true

      opts.autocmds = opts.autocmds or {}

      local function sync_indent_defaults(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then return end

        local bo = vim.bo[bufnr]
        if not bo.modifiable then return end
        if bo.buftype ~= "" and bo.buftype ~= "acwrite" then return end
        if bo.filetype == "" or bo.filetype == "make" then return end

        bo.tabstop = vim.go.tabstop
        bo.shiftwidth = vim.go.shiftwidth
        bo.softtabstop = vim.go.softtabstop
        bo.expandtab = vim.go.expandtab
        bo.autoindent = true
      end

      opts.autocmds.indent_defaults = {
        {
          event = { "FileType", "BufEnter" },
          desc = "Keep language-specific indent logic, but follow the editor default indent width",
          callback = function(args) vim.schedule(function() sync_indent_defaults(args.buf) end) end,
        },
      }

      return opts
    end,
  },
}
