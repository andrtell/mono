require "tangerine".setup {
  compiler = {
    verbose = false,
    hooks = {
      "oninit",
      "onsave",
    },
  },
}
