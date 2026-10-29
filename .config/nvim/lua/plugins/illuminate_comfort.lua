return {
  {
    "RRethy/vim-illuminate",
    opts = function(_, opts)
      opts = opts or {}
      opts.providers = { "lsp", "regex" }
      opts.filetypes_denylist = opts.filetypes_denylist or {}

      for _, ft in ipairs({ "markdown", "Avante", "alpha" }) do
        if not vim.tbl_contains(opts.filetypes_denylist, ft) then
          table.insert(opts.filetypes_denylist, ft)
        end
      end

      return opts
    end,
  },
}
