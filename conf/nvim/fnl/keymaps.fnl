(local keys
     [[:n "<BS>" ":nohl<CR>"] 
      [:i "jk" "<ESC>"] 
      [:n "<C-h>" "<C-w><C-h>"]
      [:n "<C-l>" "<C-w><C-l>"]
      [:n "<C-j>" "<C-w><C-j>"]
      [:n "<C-k>" "<C-w><C-k>"]
      [:n "-" ":Ex<CR>"]
      [:n "*" "g*"]])

(each [_ [m l r] (ipairs keys)]
  (vim.keymap.set m l r {:silent true}))
