local packages_dir = (vim.fn.stdpath("config") .. "/packages")

local lazy_dir = (packages_dir .. "/lazy.nvim")

if not vim.uv.fs_stat(lazy_dir) then
  local cmd = {
    "git", 
    "clone", 
    "--filter=blob:none", 
    "--branch=stable", 
    "https://github.com/folke/lazy.nvim.git", 
    lazy_dir
  }
  local out = vim.fn.system(cmd)
  local err = out:gsub("%s+", " ")
  if (vim.v.shell_error ~= 0) then
    io.write(err)
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazy_dir)

vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("lazy").setup({
  root = packages_dir, 
  lockfile = (packages_dir .. "/lazy-lock.json"), 
  spec = {
    {"udayvir-singh/tangerine.nvim"},
    {import = "spec"}
  }, 
  change_detection = {
    notify = false
  }, 
  install = { 
    colorscheme = { "quiet" } 
  }
})

require("tangerine").setup({
  compiler = {
    verbose = false,
    hooks = {
      "onsave",
      "oninit"
    }
  }
})

require("options")
require("keymaps")
require("statusline")
require("colors")
require("netrw")
require("diagnostic")
