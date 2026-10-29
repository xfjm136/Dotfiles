-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo(
  { { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } },
    true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

-- init.lua

-- Neovide specific settings
if vim.fn.exists "g:neovide" == 1 then
  local ime_ns = vim.api.nvim_create_namespace "neovide-ime"
  local ime_state = { bufnr = nil, mark = nil }

  local function clear_preedit()
    if ime_state.bufnr and vim.api.nvim_buf_is_valid(ime_state.bufnr) then
      vim.api.nvim_buf_clear_namespace(ime_state.bufnr, ime_ns, 0, -1)
    end
    ime_state.bufnr = nil
    ime_state.mark = nil
  end

  -- 设置Neovide启动时的缩放比例
  vim.g.neovide_scale_factor = 1.0 -- 将缩放比例设置为1.0（100%）

  -- 设置背景透明与模糊
  vim.g.neovide_opacity = 0.85
  vim.g.neovide_window_blurred = true
  -- 可选：设置启动时的字符列数和行数
  vim.opt.columns = 120 -- 设置窗口宽度为120列字符
  vim.opt.lines = 30 -- 设置窗口高度为30行字符
  vim.o.guifont = "JetBrainsMono Nerd Font:h12:b" --设置Neovide字体
  vim.g.neovide_cursor_vfx_mode = "railgun" --设置光标例子
  vim.g.neovide_input_ime = true

  vim.api.nvim_set_hl(0, "NeovideIMEPreedit", { undercurl = true, sp = "#89b4fa", italic = true })

  if type(neovide) == "table" then
    neovide.preedit_handler = function(preedit_text, _, _)
      clear_preedit()
      if not preedit_text or preedit_text == "" then return end

      local bufnr = vim.api.nvim_get_current_buf()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local row = cursor[1] - 1
      local col = cursor[2]

      ime_state.bufnr = bufnr
      ime_state.mark = vim.api.nvim_buf_set_extmark(bufnr, ime_ns, row, col, {
        virt_text = { { preedit_text, "NeovideIMEPreedit" } },
        virt_text_pos = "inline",
        hl_mode = "combine",
      })
    end

    neovide.commit_handler = function(commit_text)
      clear_preedit()
      if commit_text and commit_text ~= "" then vim.api.nvim_input(commit_text) end
    end
  end

  vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave", "ModeChanged" }, {
    callback = clear_preedit,
    desc = "Clear Neovide IME preedit virtual text",
  })
end

require "lazy_setup"
require "polish"
-- options.lua

-- 设置相对行号为 false
vim.opt.relativenumber = false

-- 设置绝对行号为 true（可选）
vim.opt.number = true
