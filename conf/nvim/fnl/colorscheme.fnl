(set vim.o.background "light")
;(vim.cmd "colorscheme binary")

(fn round [val] 
  (let [a (^ 2 52) 
		b (^ 2 51)
		c (+ a b)]
	(- (+ val c) c)))

(fn hsl [h s l]
  (let [s (/ s 100)
		l (/ l 100)
		a (* s (math.min l (- 1 l)))
		f (fn [n] (let [k (% (+ n (/ h 30)) 12)
						b (math.max (math.min (- k 3) (- 9 k) 1) -1)]
					(- l (* a b))))
		r (round (* 255 (f 0)))
		g (round (* 255 (f 8)))
		b (round (* 255 (f 4)))]
	(string.format "#%02x%02x%02x" r g b)))

(local fg
	   {
	   :red 	(hsl 0   100 50) 
	   :orange 	(hsl 39  100 50)
	   :yellow 	(hsl 60  100 50)
	   :green 	(hsl 120 100 25)
	   :blue 	(hsl 240 100 50)
	   :purple  (hsl 300 100 50)
	   :black   (hsl 0   0   0)
	   })

(local bg
	   { 
	   :yellow 	(hsl 60 73 87) 
	   :white   (hsl 0  0  100)
	   })

(fn set-hl [group vals] (vim.api.nvim_set_hl 0 group vals))

(let [all_groups (vim.api.nvim_get_hl 0 {})]
  (each [group _ (pairs all_groups)]
	(let [string? (= (type group) "string")]
	  (if string? 
		  (set-hl group {:fg fg.black :bg bg.white :force true})))))

(local rev [
  :Cursor  
  :CursorLine  
  :PmenuSel  
  :QuickFixLine  
  :Search  
  :Substitute  
  :TabLineSel  
  :TermCursor  
  :TermCursorNC  
  :VisualNOS  
  :WildMenu  
  :LspReferenceText  
  :LspReferenceRead  
  :LspReferenceWrite  
  :LspSignatureActiveParameter  
])

(each [_ group (ipairs rev)]
	(set-hl group {:fg bg.white :bg fg.black :force true}))

(set-hl :Visual {:fg fg.black :bg bg.yellow :force true})
(set-hl :Search {:fg fg.black :bg bg.yellow :force true})
(set-hl :IncSearch {:fg fg.black :bg bg.yellow :force true})
(set-hl :MatchParen {:fg fg.green :bg fg.white :force true :reverse false})
