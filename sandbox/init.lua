-- Minimal standalone sandbox init.lua for strudel live-coding
-- Completely isolated from ~/.config/nvim

local root = vim.fn.stdpath("data") .. "/sandbox-site"
local lazypath = root .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true

-- Setup plugins
require("lazy").setup({
  {
    "gruvw/strudel.nvim",
    build = "PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm install puppeteer",
    opts = {
      browser_exec_path = "/usr/bin/chromium",
      ui = {
        maximise_menu_panel = true,
      },
      start_on_launch = true,
      sync_cursor = true,
    },
    config = function(_, opts)
      require("strudel").setup(opts)
    end,
    keys = {
      { "<leader>ml", "<cmd>StrudelLaunch<cr>", desc = "Music: Launch Strudel" },
      { "<leader>mp", "<cmd>StrudelToggle<cr>", desc = "Music: Play/Pause Toggle" },
      { "<leader>mu", "<cmd>StrudelUpdate<cr>", desc = "Music: Update Pattern" },
      { "<leader>ms", "<cmd>StrudelStop<cr>", desc = "Music: Stop Audio" },
      { "<leader>mq", "<cmd>StrudelQuit<cr>", desc = "Music: Quit Strudel" },
    },
  },
}, {
  root = root .. "/plugins",
})

print("Strudel Sandbox ready! Press <leader>ml or run :StrudelLaunch to start audio.")
