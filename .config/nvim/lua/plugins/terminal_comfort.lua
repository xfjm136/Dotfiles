return {
  {
    "akinsho/toggleterm.nvim",
    opts = function(_, opts)
      opts = opts or {}

      local previous_on_open = opts.on_open

      opts.start_in_insert = true
      opts.insert_mappings = true
      opts.persist_mode = false
      opts.shade_terminals = false
      opts.shading_factor = 0
      opts.highlights = vim.tbl_deep_extend("force", opts.highlights or {}, {
        Normal = { link = "Normal" },
        NormalNC = { link = "Normal" },
        NormalFloat = { link = "Normal" },
        FloatBorder = { link = "FloatBorder" },
      })
      opts.float_opts = vim.tbl_deep_extend("force", opts.float_opts or {}, {
        winblend = 0,
      })

      opts.on_open = function(term)
        if previous_on_open then previous_on_open(term) end
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(term.bufnr) and vim.bo[term.bufnr].buftype == "terminal" then
            if term.window and vim.api.nvim_win_is_valid(term.window) then
              vim.api.nvim_set_option_value(
                "winhighlight",
                "Normal:Normal,NormalNC:Normal,NormalFloat:Normal,FloatBorder:FloatBorder",
                { win = term.window }
              )
            end
            vim.cmd.startinsert()
          end
        end)
      end
    end,
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      opts = opts or {}
      opts.autocmds = opts.autocmds or {}
      opts.autocmds.terminal_comfort = {
        {
          event = { "TermOpen", "BufEnter" },
          pattern = "term://*",
          desc = "Keep terminal readable and ready for input",
          callback = function(args)
            if vim.bo[args.buf].buftype ~= "terminal" then return end

            local opt = vim.opt_local
            opt.number = false
            opt.relativenumber = false
            opt.foldcolumn = "0"
            opt.signcolumn = "no"
            opt.cursorline = false
            opt.winhighlight = "Normal:Normal,NormalNC:NormalNC,FloatBorder:FloatBorder,NormalFloat:Normal"

            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(args.buf) and vim.api.nvim_get_current_buf() == args.buf then
                vim.cmd.startinsert()
              end
            end)
          end,
        },
      }

      return opts
    end,
  },
}
