local function load_private_env(path)
  local file = io.open(path, "r")
  if not file then return {} end

  local env = {}
  for line in file:lines() do
    local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed ~= "" and not trimmed:match("^#") then
      trimmed = trimmed:gsub("^export%s+", "")
      local key, value = trimmed:match("^([%w_]+)%s*=%s*(.*)$")
      if key and value then
        value = value:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
        env[key] = value
      end
    end
  end

  file:close()
  return env
end

local private_env = load_private_env(vim.fn.expand "~/.config/private/ai.env")
if private_env.DEEPSEEK_API_KEY and private_env.DEEPSEEK_API_KEY ~= "" then
  vim.env.DEEPSEEK_API_KEY = private_env.DEEPSEEK_API_KEY
end

return {
  -- ==========================================
  -- 1. Avante.nvim (DeepSeek 接入)
  -- ==========================================
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,

    -- 【关键修改】：改回 "make"
    -- 这样 Avante 就会优先尝试下载官方预编译的二进制文件 (avante_lib.so)
    -- 如果下载失败，它才会尝试本地编译
    build = "make",

    opts = {
      provider = "deepseek",
      providers = {
        deepseek = {
          __inherited_from = "openai",
          endpoint = "https://api.deepseek.com",
          model = "deepseek-v4-pro",
          api_key_name = "DEEPSEEK_API_KEY",
        },
      },
      behaviour = {
        auto_suggestions = false,
      },
    },

    config = function(_, opts)
      require("avante").setup(opts)

      local avante_utils = require("avante.utils")
      local fallback_path = function()
        local project_root = avante_utils.get_project_root()
        if type(project_root) == "string" and project_root ~= "" then return vim.fs.normalize(project_root) end
        return vim.uv.cwd()
      end

      local helpers = require("avante.llm_tools.helpers")
      local original_get_abs_path = helpers.get_abs_path
      helpers.get_abs_path = function(rel_path)
        if rel_path == nil or rel_path == vim.NIL or rel_path == "" then return fallback_path() end
        return original_get_abs_path(rel_path)
      end

      local bash = require("avante.llm_tools.bash")
      local original_bash_func = bash.func
      bash.func = function(input, tool_opts)
        input = input or {}
        if input.path == nil or input.path == vim.NIL or input.path == "" then input.path = fallback_path() end
        return original_bash_func(input, tool_opts)
      end
    end,

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = { insert_mode = true },
            use_absolute_path = false,
            relative_to_current_file = true,
            dir_path = "attachments",
            copy_images = true,
            file_name = "%Y-%m-%d-%H-%M-%S",
          },
          filetypes = {
            markdown = {
              url_encode_path = true,
              template = "![$CURSOR]($FILE_PATH)",
              download_images = false,
            },
          },
        },
      },
      "MeanderingProgrammer/render-markdown.nvim",
    },
  },

  -- ==========================================
  -- 2. Minuet-ai.nvim (保持不变)
  -- ==========================================
  {
    "milanglacier/minuet-ai.nvim",
    lazy = false, -- 强制立即加载
    dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },

    config = function()
    require("minuet").setup({
      -- 调试开关
      -- notify = 'debug',

      -- 代理设置
      -- proxy = "http://127.0.0.1:7890",

      request_timeout = 30,
      throttle = 1000,
      debounce = 400,

      provider = 'openai_compatible',
      n_completions = 3,
      context_window = 4096,
      cmp = {
        enable_auto_complete = false,
      },
      blink = {
        enable_auto_complete = false,
      },

      provider_options = {
        openai_compatible = {
          -- 【核心修复步骤 2】: 这里填环境变量的“名字”，不是 Key 本身
          -- Minuet 看到这个字符串后，会去 vim.env 里找上面设置的 DEEPSEEK_API_KEY
          api_key = "DEEPSEEK_API_KEY",

          name = "DeepSeek",
          end_point = "https://api.deepseek.com/chat/completions",
          model = "deepseek-v4-flash",
          stream = true,
          system = {
            -- 我们重写 'prompt' 部分，加入中文指令
            -- 注意：必须保留 Input markers 的定义，否则 DeepSeek 看不懂输入格式
            prompt = [[
              You are an AI code completion engine. Provide contextually appropriate completions.

              **CRITICAL RULE: If you generate comments or documentation, YOU MUST USE SIMPLIFIED CHINESE (简体中文).**

              Input markers:
              - <contextAfterCursor>: Context after cursor
              - <cursorPosition>: Current cursor location
              - <contextBeforeCursor>: Context before cursor
            ]],

            -- 可选：如果你觉得默认的 guidelines (英文) 干扰了模型
            -- 也可以在这里重写 guidelines 为中文，进一步强化中文语境
            guidelines = [[
              Guidelines:
              1. Offer completions after the <cursorPosition> marker.
              2. Maintain the user's existing whitespace and indentation STRICTLY.
              3. Keep completions concise.
              4. DO NOT include markdown code blocks.
              5. **Remember: Comments must be in Chinese.**
            ]],
          },
          optional = {
            max_tokens = 256,
            stop = nil,
            thinking = { type = "disabled" },
          },
        },
      },

      virtualtext = {
        auto_trigger_ft = {}, -- 默认不自动触发，改为手动启动
        keymap = {
          accept = nil,
          dismiss = nil,
          next = "<A-.>",
          prev = "<A-,>",
          -- 禁用不需要的键
          accept_line = nil,
          accept_n_lines = nil,
        },
      },
    })

    local virtualtext = require("minuet.virtualtext").action

    vim.keymap.set("i", "<A-a>", function()
      if virtualtext.is_visible() then
        virtualtext.accept()
      else
        virtualtext.next()
      end
    end, {
      desc = "[minuet.virtualtext] trigger or accept suggestion",
      silent = true,
    })

    vim.keymap.set("i", "<A-q>", virtualtext.dismiss, {
      desc = "[minuet.virtualtext] dismiss suggestion",
      silent = true,
    })
    end,
  },
  -- 【强制重命名菜单】
  -- 直接告诉 which-key 插件：<Leader>a 是一个组，名字叫 "Avante AI"
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function(_, opts)
    -- 确保 spec 表存在
    if not opts.spec then opts.spec = {} end

      -- 插入新的组名定义
      table.insert(opts.spec, {
        mode = { "n", "v" }, -- 在 Normal 和 Visual 模式下都生效
        { "<Leader>a", group = "Avante AI" }, -- 您可以换成喜欢的图标
      })
      end,
  },
}
