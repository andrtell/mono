-- [nfnl] Compiled from init.fnl by https://github.com/Olical/nfnl, do not edit.
local function file_exists_3f(path)
  return vim.uv.fs_stat(path)
end
local function shell_error_3f()
  return not (vim.v.shell_error == 0)
end
local function die(error_message)
  io.write(error_message)
  return os.exit(1)
end
local function clone_lazy(target_dir)
  local cmd = {"git", "clone", "--filter=blob:none", "--branch=stable", "https://github.com/folke/lazy.nvim.git", target_dir}
  return vim.fn.system(cmd)
end
local function clone_lazy_or_die(target_dir)
  local out = clone_lazy(target_dir)
  local msg = out:gsub("%s+", " ")
  if shell_error_3f() then
    return die(msg)
  else
    return nil
  end
end
local function install_lazy(packages_dir)
  local lazy_dir = (packages_dir .. "/lazy.nvim")
  if not file_exists_3f(lazy_dir) then
    clone_lazy_or_die(lazy_dir)
  else
  end
  return vim.opt.rtp:prepend(lazy_dir)
end
local packages_dir = (vim.fn.stdpath("config") .. "/packages")
install_lazy(packages_dir)
vim.g.mapleader = " "
vim.g.maplocalleader = ","
local config = {root = packages_dir, lockfile = (packages_dir .. "/lazy-lock.json"), spec = {{"Olical/nfnl", ft = "fennel"}, {import = "spec"}}, checker = {enabled = false}, install = {colorscheme = {"quiet"}}}
do
  local lazy = require("lazy")
  lazy.setup(config)
end
require("options")
require("interface")
return require("keymaps")
