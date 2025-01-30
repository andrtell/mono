return {
  "udayvir-singh/tangerine.nvim",
  ft = {"fennel"},
  opts = {
    compiler = {
      verbose = false,
      hooks = {
        "onsave",
        "oninit"
      },
    },
    keymaps = {
      eval_buffer = "<localleader>e",
      peek_buffer = "<localleader>l",
      peek_buffer = "go",
    }
  }
}
