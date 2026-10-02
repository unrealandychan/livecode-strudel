-- LazyVim plugin configuration for gruvw/strudel.nvim
-- Place this file at: ~/.config/nvim/lua/plugins/strudel.lua
-- (or copy it directly: cp /home/arch/Projects/livecode-strudel/plugin-spec/strudel.lua ~/.config/nvim/lua/plugins/strudel.lua)

return {
  "gruvw/strudel.nvim",
  -- Skip downloading bundled Chromium (~300MB) since Arch has /usr/bin/chromium
  build = "PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm install puppeteer yargs@latest",
  -- Lazy-load only when opening music files or running Strudel commands
  cmd = {
    "StrudelLaunch",
    "StrudelQuit",
    "StrudelToggle",
    "StrudelUpdate",
    "StrudelStop",
    "StrudelSetBuffer",
  },
  ft = { "strudel", "str", "std" },
  opts = {
    -- Explicitly use Arch Linux system Chromium
    browser_exec_path = "/usr/bin/chromium",
    ui = {
      maximise_menu_panel = true,
      hide_menu_panel = false,
      hide_top_bar = false,
      hide_code_editor = false,
      hide_error_display = false,
    },
    start_on_launch = true,
    update_on_save = false,
    sync_cursor = true,
    report_eval_errors = true,
  },
  config = function(_, opts)
    require("strudel").setup(opts)
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = vim.api.nvim_create_augroup("StrudelCleanupOnExit", { clear = true }),
      callback = function()
        pcall(function()
          require("strudel").quit()
        end)
      end,
    })
  end,
  -- Dedicated music livecoding keymaps (<leader>m...)
  keys = {
    { "<leader>m", desc = "+music/strudel" },
    { "<leader>ml", "<cmd>StrudelLaunch<cr>", desc = "Music: Launch Strudel" },
    { "<leader>mp", "<cmd>StrudelToggle<cr>", desc = "Music: Play/Pause Toggle" },
    { "<leader>mu", "<cmd>StrudelUpdate<cr>", desc = "Music: Update Pattern" },
    { "<leader>ms", "<cmd>StrudelStop<cr>", desc = "Music: Stop Audio" },
    { "<leader>mq", "<cmd>StrudelQuit<cr>", desc = "Music: Quit Strudel" },
  },
}
