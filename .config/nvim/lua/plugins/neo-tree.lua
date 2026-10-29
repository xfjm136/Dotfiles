return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      -- 功能 1: 自动跟随当前打开的文件
      -- 如果你打开了 src/main.js，文件树会自动展开到 src/ 目录，而不是停留在根目录
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false, -- 离开目录时自动折叠，保持界面清爽
      },

      -- 功能 2: 过滤规则 (解决“臃肿”的核心)
      filtered_items = {
        visible = false, -- 【关键】一定要设为 false，否则下面的规则都不生效，会显示所有垃圾文件

        hide_dotfiles = false, -- 允许显示 . 开头的隐藏文件 (如 .env, .config)
        hide_gitignored = true, -- 隐藏被 git 忽略的文件 (如 node_modules)，防止刷屏

        -- 你可以在这里强制隐藏特定的“烦人”文件
        hide_by_name = {
          ".git", -- 隐藏 .git 文件夹 (通常我们不需要在文件树里操作它)
          ".DS_Store", -- Mac 系统的垃圾文件
          "thumbs.db", -- Windows 系统的垃圾文件
        },
      },
    },
  },
}
