-- :fennel:1738249993
vim.o.background = "light"
local function round(val)
  local a = (2 ^ 52)
  local b = (2 ^ 51)
  local c = (a + b)
  return ((val + c) - c)
end
local function hsl(h, s, l)
  local s0 = (s / 100)
  local l0 = (l / 100)
  local a = (s0 * math.min(l0, (1 - l0)))
  local f
  local function _1_(n)
    local k = ((n + (h / 30)) % 12)
    local b = math.max(math.min((k - 3), (9 - k), 1), -1)
    return (l0 - (a * b))
  end
  f = _1_
  local r = round((255 * f(0)))
  local g = round((255 * f(8)))
  local b = round((255 * f(4)))
  return string.format("#%02x%02x%02x", r, g, b)
end
local function w(l)
  return hsl(0, 0, l)
end
local function r(s, l)
  return hsl(0, s, l)
end
local function o(s, l)
  return hsl(39, s, l)
end
local function y(s, l)
  return hsl(60, s, l)
end
local function g(s, l)
  return hsl(120, s, l)
end
local function b(s, l)
  return hsl(220, s, l)
end
local function p(s, l)
  return hsl(300, s, l)
end
local function pi(s, l)
  return hsl(350, s, l)
end
local function set_hl(group, opts)
  local bw = {fg = w(1), bg = w(99.5)}
  return vim.api.nvim_set_hl(0, group, vim.tbl_deep_extend("force", {force = true}, bw, opts))
end
local function reset_hl()
  local all_groups = vim.api.nvim_get_hl(0, {})
  for group, _ in pairs(all_groups) do
    local string_3f = (type(group) == "string")
    if string_3f then
      set_hl(group, {})
    else
    end
  end
  return nil
end
reset_hl()
do
  local gray = w(94)
  local red = r(75, 94)
  local blue = b(75.5, 93.5)
  local orange = o(75, 91)
  local yellow = y(75, 87)
  local green = g(76, 91)
  local purple = p(75, 93)
  set_hl("Search", {bg = orange})
  set_hl("IncSearch", {bg = orange})
  set_hl("CurSearch", {bg = orange})
  set_hl("Visual", {bg = blue})
  set_hl("VisualNOS", {bg = yellow})
  set_hl("MatchParen", {fg = w(0), bg = red})
  set_hl("PmenuSel", {fg = w(0), bg = w(85)})
  set_hl("Pmenu", {fg = w(0), bg = gray})
  set_hl("StatusLine", {fg = w(0), bg = gray})
  set_hl("LeapLabelPrimary", {bg = purple})
  set_hl("netrwMarkFile", {bg = yellow})
  set_hl("endofbuffer", {fg = w(99.5)})
  set_hl("DiagnosticUnderlineError", {bg = red})
end
local blue = b(4, 63)
set_hl("Comment", {fg = blue})
return set_hl("@comment", {fg = blue})