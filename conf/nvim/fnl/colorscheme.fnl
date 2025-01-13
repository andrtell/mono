(set vim.o.background "light")

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

(local black "#000000")
(local white "#fefefd")

(fn set-hl [group opts] 
  (let [defaults {:fg black :bg white :force true}]
  	(vim.api.nvim_set_hl 0 group (vim.tbl_deep_extend "force" {} defaults opts))))

(local gray
	   {
	   10   (hsl 0  0  10)
	   15   (hsl 0  0  15)
	   20   (hsl 0  0  20)
	   25   (hsl 0  0  25)
	   30   (hsl 0  0  30)
	   35   (hsl 0  0  35)
	   40   (hsl 0  0  40)
	   50   (hsl 0  0  50)
	   90   (hsl 0  0  90)
	   95   (hsl 0  0  95)
	   })

(local fg
	   {
	   :red 	(hsl 0   100 50) 
	   :orange 	(hsl 39  100 50)
	   :yellow 	(hsl 60  100 50)
	   :green 	(hsl 120 100 25)
	   :blue 	(hsl 240 100 50)
	   :purple  (hsl 300 100 50)
	   })

(local bg
	   { 
	   :yellow 	(hsl 60 64 89) 
	   :green 	(hsl 120 76 91) 
	   ;; --
	   :red 	(hsl 0 68 92) 
	   :orange 	(hsl 39 68 88) 
	   :blue 	(hsl 240 68 88) 
	   })


(let [all_groups (vim.api.nvim_get_hl 0 {})]
  (each [group _ (pairs all_groups)]
	(let [string? (= (type group) "string")]
	  (if string? (set-hl group {})))))

(local rev [
  :CursorLine  
  :PmenuSel  
  :QuickFixLine  
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
	(set-hl group {:fg white :bg black :force true}))

(set-hl :Search 	{:bg bg.yellow})
(set-hl :IncSearch 	{:bg bg.yellow})
(set-hl :Visual 	{:bg bg.yellow})
(set-hl :MatchParen {:fg fg.green :reverse false})

(set-hl :Cursor {:fg white :bg (. gray 10)})
(set-hl :PmenuSel {:fg white :bg (. gray 35)})


