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

-- Register .str and .std filetypes as javascript so gcc and treesitter work
vim.filetype.add({
  extension = {
    str = "javascript",
    std = "javascript",
  },
})

-- Setup plugins
require("lazy").setup({
  {
    "gruvw/strudel.nvim",
    build = "PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm install puppeteer yargs@latest",
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
      -- Headless mode: no browser window popup! Pure terminal livecoding.
      headless = true,
      browser_exec_path = "/usr/bin/chromium",
      ui = {
        maximise_menu_panel = true,
      },
      start_on_launch = true,
      sync_cursor = true,
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
