return {
  "nvim-treesitter/nvim-treesitter",
  config = function(plugin, opts)
    require("astronvim.plugins.configs.nvim-treesitter")(plugin, opts)

    local query = require "vim.treesitter.query"

    local non_filetype_match_injection_language_aliases = {
      ex = "elixir",
      pl = "perl",
      sh = "bash",
      ts = "typescript",
      uxn = "uxntal",
    }

    local opts = vim.fn.has "nvim-0.10" == 1 and { force = true, all = false } or true

    local function parser_from_info_string(alias)
      local match = vim.filetype.match { filename = "a." .. alias }
      return match or non_filetype_match_injection_language_aliases[alias] or alias
    end

    local function normalize_node(node)
      if type(node) == "table" then return node[#node] or node[1] end
      return node
    end

    query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
      local capture_id = pred[2]
      local node = normalize_node(match[capture_id])
      if not node then return end

      local ok_text, text = pcall(vim.treesitter.get_node_text, node, bufnr)
      if not ok_text or type(text) ~= "string" or text == "" then return end

      metadata["injection.language"] = parser_from_info_string(text:lower())
    end, opts)
  end,
}
