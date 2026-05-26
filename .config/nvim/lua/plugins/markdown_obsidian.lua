local function set_markdown_highlights()
  local set_hl = vim.api.nvim_set_hl

  set_hl(0, "RenderMarkdownCode", { bg = "#242938" })
  set_hl(0, "RenderMarkdownCodeBorder", { fg = "#6f7993", bg = "#242938" })
  set_hl(0, "RenderMarkdownCodeInfo", { fg = "#9dc7ff", bg = "#242938", italic = true })
  set_hl(0, "RenderMarkdownCodeFallback", { fg = "#cad3f5", bg = "#242938" })
  set_hl(0, "RenderMarkdownCodeInline", { fg = "#f2cd8f", bg = "#2d3344", italic = true })
  set_hl(0, "RenderMarkdownInlineHighlight", { fg = "#f5e0dc", bg = "NONE", bold = true, underline = true })
  set_hl(0, "RenderMarkdownQuote", { fg = "#8ec5ff" })
  set_hl(0, "RenderMarkdownQuote1", { fg = "#8ec5ff" })
  set_hl(0, "RenderMarkdownQuote2", { fg = "#7dc4b8" })
  set_hl(0, "RenderMarkdownQuote3", { fg = "#b6c3ff" })
  set_hl(0, "RenderMarkdownBullet", { fg = "#b6c3ff" })
  set_hl(0, "RenderMarkdownTableHead", { fg = "#89b4fa", bg = "NONE", bold = true, underline = true })
  set_hl(0, "RenderMarkdownTableRow", { fg = "#cdd6f4", bg = "NONE" })
  set_hl(0, "RenderMarkdownH1Bg", { bg = "NONE" })
  set_hl(0, "RenderMarkdownH2Bg", { bg = "NONE" })
  set_hl(0, "RenderMarkdownH3Bg", { bg = "NONE" })
  set_hl(0, "RenderMarkdownH4Bg", { bg = "NONE" })
  set_hl(0, "RenderMarkdownH5Bg", { bg = "NONE" })
  set_hl(0, "RenderMarkdownH6Bg", { bg = "NONE" })
  set_hl(0, "RenderMarkdownH1", { fg = "#89b4fa", bold = true })
  set_hl(0, "RenderMarkdownH2", { fg = "#74c7ec", bold = true })
  set_hl(0, "RenderMarkdownH3", { fg = "#94e2d5", bold = true })
  set_hl(0, "RenderMarkdownH4", { fg = "#b4befe", bold = true })
  set_hl(0, "RenderMarkdownH5", { fg = "#cba6f7", bold = true })
  set_hl(0, "RenderMarkdownH6", { fg = "#f5c2e7", bold = true })
end

local function open_markdown_preview_for(path)
  local picker = require "obsidian.picker"
  local normalized_target = vim.fs.normalize(path)
  local preview = require "render-markdown.core.preview"
  local manager = require "render-markdown.core.manager"
  local render_markdown = require "render-markdown"

  local function resolve_origin_win(bufnr)
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        if vim.api.nvim_win_is_valid(win) then
          return win
        end
      end
    end

    local current = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_is_valid(current) then
      return current
    end

    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        return win
      end
    end

    error "No valid window available for markdown preview"
  end

  local function find_quick_preview()
    for src_buf, preview_buf in pairs(preview.buffers) do
      if vim.api.nvim_buf_is_valid(preview_buf) and vim.b[preview_buf].obsidian_quick_preview then
        return src_buf, preview_buf
      end
    end
  end

  local function clear_quick_preview()
    local src_buf, preview_buf = find_quick_preview()
    if preview_buf and vim.api.nvim_buf_is_valid(preview_buf) then
      vim.api.nvim_buf_delete(preview_buf, { force = true })
    end
    if src_buf and vim.api.nvim_buf_is_valid(src_buf) and vim.fn.bufwinid(src_buf) == -1 then
      vim.api.nvim_buf_delete(src_buf, { force = true })
    end
  end

  local origin_buf = picker.state.calling_bufnr
  local origin_win = resolve_origin_win(origin_buf)
  local origin_ft = origin_buf and vim.bo[origin_buf].filetype or vim.bo.filetype

  clear_quick_preview()

  if origin_ft == "alpha" then
    vim.api.nvim_win_call(origin_win, function()
      vim.cmd("edit " .. vim.fn.fnameescape(normalized_target))
      local render_buf = vim.api.nvim_get_current_buf()
      if not manager.attached(render_buf) then
        vim.api.nvim_exec_autocmds("FileType", { buffer = render_buf, modeline = false })
      end
      render_markdown.buf_enable()
      render_markdown.render { buf = render_buf, win = origin_win, event = "ObsidianQuickPreview" }
    end)
    return
  end

  local source_win, source_buf, preview_buf
  vim.api.nvim_win_call(origin_win, function()
    vim.cmd("rightbelow vsplit")
    source_win = vim.api.nvim_get_current_win()

    vim.cmd("edit " .. vim.fn.fnameescape(normalized_target))
    source_buf = vim.api.nvim_get_current_buf()
    vim.bo[source_buf].buflisted = false
    vim.bo[source_buf].bufhidden = "hide"

    if not manager.attached(source_buf) then
      vim.api.nvim_exec_autocmds("FileType", { buffer = source_buf, modeline = false })
    end

    render_markdown.preview()
    preview_buf = preview.buffers[source_buf]
  end)

  if preview_buf and vim.api.nvim_buf_is_valid(preview_buf) then
    vim.b[source_buf].obsidian_quick_preview = true
    vim.b[preview_buf].obsidian_quick_preview = true
  end

  if vim.api.nvim_win_is_valid(source_win) then
    vim.api.nvim_win_close(source_win, true)
  end

  if vim.api.nvim_win_is_valid(origin_win) then
    vim.api.nvim_set_current_win(origin_win)
  end
end

local function obsidian_quick_switch_preview()
  local picker = require "obsidian.picker"
  picker.find_notes {
    prompt_title = "Quick Switch Preview",
    no_default_mappings = true,
    callback = function(path)
      if path and path ~= "" then
        open_markdown_preview_for(path)
      end
    end,
  }
end

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    cmd = { "RenderMarkdown" },
    ft = { "markdown", "Avante" },
    opts = function(_, opts)
      opts = opts or {}
      opts.preset = "obsidian"
      opts.file_types = { "markdown", "Avante" }
      opts.render_modes = { "n", "c", "t" }
      opts.completions = { lsp = { enabled = true } }
      opts.anti_conceal = {
        enabled = true,
      }
      opts.heading = {
        icons = { "󰼏 ", "󰎨 ", "󰼑 ", "󰎲 ", "󰼓 ", "󰎴 " },
      }
      opts.bullet = {
        icons = { "●", "○", "◆", "◇" },
        left_pad = 1,
      }
      opts.checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        },
      }
      opts.code = {
        width = "block",
        border = "thin",
        left_margin = 1,
        left_pad = 1,
        right_pad = 1,
        above = "╌",
        below = "╌",
        language_border = "╌",
        language_left = " ",
        language_right = " ",
      }
      opts.quote = {
        icon = "▋",
        repeat_linebreak = false,
      }
      opts.pipe_table = { preset = "round", cell = "padded" }
      opts.sign = { enabled = false }
      opts.win_options = {
        conceallevel = {
          default = 2,
          rendered = 3,
        },
        concealcursor = {
          default = "nc",
          rendered = "",
        },
      }
      return opts
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, {
        "markdown",
        "markdown_inline",
        "html",
        "yaml",
      })
    end,
  },
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    event = {
      "BufReadPre /data/Obsidian_Notebook/知识库/**.md",
      "BufNewFile /data/Obsidian_Notebook/知识库/**.md",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      legacy_commands = false,
      log_level = vim.log.levels.ERROR,
      workspaces = {
        {
          name = "knowledge",
          path = "/data/Obsidian_Notebook/知识库",
        },
      },
      picker = {
        name = "snacks.pick",
      },
      link = {
        style = "wiki",
        format = "shortest",
      },
      completion = {
        nvim_cmp = false,
        blink = true,
        min_chars = 2,
      },
      ui = {
        enable = false,
        ignore_conceal_warn = true,
      },
      daily_notes = {
        folder = "daily",
      },
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },
      frontmatter = {
        func = function(note)
          local out = { id = note.id, aliases = note.aliases, tags = note.tags }
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end
          return out
        end,
      },
      open = {
        use_advanced_uri = false,
        func = vim.ui.open,
      },
    },
    keys = {
      {
        "gf",
        function()
          if require("obsidian").util.cursor_on_markdown_link() then
            return "<Cmd>Obsidian follow_link<CR>"
          end
          return "gf"
        end,
        expr = true,
        desc = "Obsidian Follow Link",
      },
      { "<leader>mb", "<Cmd>Obsidian backlinks<CR>", desc = "Obsidian Backlinks" },
      { "<leader>mp", "<Cmd>PasteImage<CR>", desc = "Markdown Paste Image" },
      { "<leader>mw", "<Cmd>setlocal spell!<CR>", desc = "Markdown Toggle Spell" },
      { "<leader>md", "<Cmd>Obsidian today<CR>", desc = "Obsidian Today" },
      { "<leader>mf", "<Cmd>Obsidian follow_link<CR>", desc = "Obsidian Follow Link" },
      { "<leader>mn", "<Cmd>Obsidian new<CR>", desc = "Obsidian New Note" },
      { "<leader>mq", "<Cmd>Obsidian quick_switch<CR>", desc = "Obsidian Quick Switch" },
      { "<leader>mQ", obsidian_quick_switch_preview, desc = "Obsidian Quick Preview Switch" },
      { "<leader>ms", "<Cmd>Obsidian search<CR>", desc = "Obsidian Search" },
      { "<leader>mt", "<Cmd>Obsidian tags<CR>", desc = "Obsidian Tags" },
      { "<leader>mR", "<Cmd>RenderMarkdown buf_toggle<CR>", desc = "Render Markdown Toggle" },
      { "<leader>mP", "<Cmd>RenderMarkdown preview<CR>", desc = "Render Markdown Preview" },
    },
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      opts = opts or {}
      opts.mappings = opts.mappings or {}
      opts.mappings.n = opts.mappings.n or {}
      opts.mappings.n["<Leader>m"] = { desc = "Markdown/Obsidian" }
      opts.autocmds = opts.autocmds or {}
      opts.autocmds.markdown_palette = {
        {
          event = { "ColorScheme", "VimEnter" },
          desc = "Apply Markdown-only highlight palette",
          callback = function()
            set_markdown_highlights()
          end,
        },
      }
      opts.autocmds.markdown_reading = {
        {
          event = { "FileType" },
          pattern = { "markdown" },
          desc = "Comfortable Markdown reading and writing defaults",
          callback = function(args)
            set_markdown_highlights()
            local opt = vim.opt_local
            opt.wrap = true
            opt.linebreak = true
            opt.breakindent = true
            opt.breakindentopt = ""
            opt.showbreak = "  "
            opt.spell = false
            opt.spelllang = { "en_us" }
            opt.conceallevel = 2
            opt.concealcursor = "nc"
            opt.textwidth = 0
            opt.colorcolumn = ""
            opt.relativenumber = false
            opt.number = true
            opt.signcolumn = "no"
            opt.foldlevel = 99
            opt.sidescrolloff = 0
            opt.scrolloff = 4
            opt.list = false

            pcall(vim.diagnostic.enable, false, { bufnr = args.buf })

            vim.bo[args.buf].formatoptions = vim.bo[args.buf].formatoptions
              :gsub("t", "")
              :gsub("c", "")
              .. "n"
          end,
        },
      }
      return opts
    end,
  },
}
