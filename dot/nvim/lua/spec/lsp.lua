-- :fennel:1738246081
local S = {}
S["mk-que"] = function(size)
  local q_cap = size
  local q_len = 0
  local q_fst = 1
  local q_lst = 1
  local q_buf = {}
  local function _1_(val)
    q_buf[q_lst] = val
    q_lst = ((q_lst % q_cap) + 1)
    if (q_len < q_cap) then
      q_len = (q_len + 1)
      return nil
    else
      q_fst = ((q_fst % q_cap) + 1)
      return nil
    end
  end
  local function _3_()
    return q_buf
  end
  local function _4_()
    return q_buf[q_fst]
  end
  local function _5_()
    return (q_len == 0)
  end
  local function _6_()
    return q_len
  end
  local function _7_()
    if (q_len == 0) then
      return nil
    else
      local val = q_buf[q_fst]
      q_buf[q_fst] = nil
      q_fst = ((q_fst % q_cap) + 1)
      q_len = (q_len - 1)
      return val
    end
  end
  return {push = _1_, data = _3_, peek = _4_, ["nil?"] = _5_, len = _6_, pop = _7_}
end
S["save-buffer"] = function(bufnr)
  if (bufnr == vim.api.nvim_get_current_buf()) then
    return vim.cmd("noa update")
  else
    return nil
  end
end
S["buffer-exists?"] = function(bufnr)
  return (0 ~= vim.fn.bufexists(bufnr))
end
S["buffer-loaded?"] = function(bufnr)
  return vim.api.nvim_buf_is_loaded(bufnr)
end
S["buffer-unchanged?"] = function(bufnr)
  return (vim.api.nvim_buf_get_var(bufnr, "jobtick") == vim.api.nvim_buf_get_var(bufnr, "changedtick"))
end
S["buffer-insert-mode?"] = function(bufnr)
  local mode = vim.api.nvim_get_mode()
  return vim.startswith(mode.mode, "i")
end
S["can-edit?"] = function(bufnr)
  return (S["buffer-exists?"](bufnr) and S["buffer-loaded?"](bufnr) and S["buffer-unchanged?"](bufnr) and not S["buffer-insert-mode?"](bufnr))
end
S["update-jobtick"] = function(bufnr)
  return vim.api.nvim_buf_set_var(bufnr, "jobtick", vim.api.nvim_buf_get_var(bufnr, "changedtick"))
end
S["client-request"] = function(handler, client_id, method, params, bufnr)
  local client = vim.lsp.get_client_by_id(client_id)
  return client.request(method, params, handler, bufnr)
end
S["apply-code-action"] = function(result, bufnr)
  for _, action in ipairs(result) do
    local _10_ = action.kind
    if (_10_ == "source.organizeImports") then
      if S["can-edit?"](bufnr) then
        vim.lsp.util.apply_workspace_edit(action.edit, "utf-16")
      else
      end
    else
    end
  end
  return nil
end
S["handle-code-action"] = function(err, result, ctx)
  local _13_, _14_, _15_ = err, result, ctx
  if ((nil ~= _13_) and true and true) then
    local err0 = _13_
    local _ = _14_
    local _0 = _15_
    return print(string.format("(LSP Error: %d): %s", err0.code, err0.message))
  elseif (true and (nil ~= _14_) and (nil ~= _15_)) then
    local _ = _13_
    local result0 = _14_
    local ctx0 = _15_
    return S["apply-code-action"](result0, ctx0.bufnr)
  else
    return nil
  end
end
S["request-code-action"] = function(handler, _17_)
  local client_id = _17_[1]
  local bufnr = _17_[2]
  local params = vim.lsp.util.make_range_params()
  params.context = {source = {organizeImports = true}}
  return S["client-request"](handler, client_id, "textDocument/codeAction", params, bufnr)
end
S["apply-format"] = function(res, bufnr)
  if S["can-edit?"](bufnr) then
    vim.lsp.util.apply_text_edits(res, bufnr, "utf-16")
    return S["update-jobtick"](bufnr)
  else
    return nil
  end
end
S["handle-format"] = function(err, result, ctx)
  local _19_, _20_, _21_ = err, result, ctx
  if ((nil ~= _19_) and true and true) then
    local err0 = _19_
    local _ = _20_
    local _0 = _21_
    return vim.lsp.log(string.format("(LSP Error: %d): %s", err0.code, err0.message))
  elseif (true and (nil ~= _20_) and (nil ~= _21_)) then
    local _ = _19_
    local result0 = _20_
    local ctx0 = _21_
    return S["apply-format"](result0, ctx0.bufnr)
  else
    return nil
  end
end
S["request-format"] = function(handler, _23_)
  local client_id = _23_[1]
  local bufnr = _23_[2]
  local params = vim.lsp.util.make_formatting_params()
  return S["client-request"](handler, client_id, "textDocument/formatting", params, bufnr)
end
S.jobs = {}
S["run-jobs"] = function(bufnr)
  local rec
  local function _24_(handler)
    local function _25_(err, res, ctx)
      handler(err, res, ctx)
      local function _26_()
        return S["run-jobs"](bufnr)
      end
      return vim.schedule(_26_)
    end
    return _25_
  end
  rec = _24_
  local jobs = S.jobs[bufnr]
  if jobs["nil?"]() then
    return S["save-buffer"](bufnr)
  else
    local _27_ = jobs.pop()
    if ((_G.type(_27_) == "table") and (nil ~= _27_[1]) and (nil ~= _27_[2]) and (nil ~= _27_[3])) then
      local requester = _27_[1]
      local handler = _27_[2]
      local args = _27_[3]
      return requester(rec(handler), args)
    else
      return nil
    end
  end
end
S["on-write-event"] = function(client_id)
  local function _30_(args)
    do
      local bufnr = args.buf
      local jobs = S.jobs[bufnr]
      local idle_3f = jobs["nil?"]()
      jobs.push({S["request-format"], S["handle-format"], {client_id, bufnr}})
      jobs.push({S["request-code-action"], S["handle-code-action"], {client_id, bufnr}})
      S["update-jobtick"](bufnr)
      if idle_3f then
        S["run-jobs"](bufnr)
      else
      end
    end
    return nil
  end
  return _30_
end
S.group = vim.api.nvim_create_augroup("LSP", {clear = false})
S["on-attach"] = function(client, bufnr)
  S.jobs[bufnr] = S["mk-que"](21)
  vim.api.nvim_clear_autocmds({group = S.group, buffer = bufnr})
  return vim.api.nvim_create_autocmd("BufWritePost", {group = S.group, buffer = bufnr, callback = S["on-write-event"](client.id)})
end
S.config = function()
  local lspconfig = require("lspconfig")
  return lspconfig.gopls.setup({on_attach = S["on-attach"]})
end
return {"neovim/nvim-lspconfig", config = S.config}