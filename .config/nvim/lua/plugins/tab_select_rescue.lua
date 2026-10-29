return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      opts = opts or {}
      opts.mappings = opts.mappings or {}
      opts.mappings.s = opts.mappings.s or {}

      -- If a completion/snippet placeholder temporarily enters Select mode,
      -- keep Tab/S-Tab from triggering visual-mode indent and cursor jumps.
      opts.mappings.s["<Tab>"] = { "<Esc>la", desc = "Leave Select mode and continue editing" }
      opts.mappings.s["<S-Tab>"] = { "<Esc>la", desc = "Leave Select mode and continue editing" }

      return opts
    end,
  },
}
