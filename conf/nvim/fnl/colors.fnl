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

(fn w [l] (hsl 0 0 l))
(fn r [s l] (hsl 0 s l))
(fn o [s l] (hsl 39 s l))
(fn y [s l] (hsl 60 s l))
(fn g [s l] (hsl 120 s l))
(fn b [s l] (hsl 220 s l))
(fn p [s l] (hsl 300 s l))

(fn set-hl [group opts] 
  (let [bw {:fg (w 0) :bg (w 100)}]
  	(vim.api.nvim_set_hl 0 group (vim.tbl_deep_extend "force" {:force true} bw opts))))

(fn reset-hl []
  (let [all_groups (vim.api.nvim_get_hl 0 {})]
	(each [group _ (pairs all_groups)] (let [string? (= (type group) "string")]
		(if string? (set-hl group {}))))))

(reset-hl)

(let [red (r 75 91) 
	  blue (b 75 91)
	  orange (o 75 91)
	  yellow (y 77 91)
	  green (g 75 91)
	  purple (p 75 93)]
	(set-hl :Search 	{:bg yellow})
	(set-hl :IncSearch 	{:bg yellow})
	(set-hl :CurSearch 	{:bg yellow})
	(set-hl :Visual 	{:bg yellow})
	(set-hl :VisualNOS 	{:bg yellow})
	(set-hl :MatchParen	{:fg (w 0) :bg red})
	(set-hl :PmenuSel 	{:fg (w 0) :bg blue})
	(set-hl :Pmenu 		{:fg (w 0) :bg (w 93)})
	(set-hl :StatusLine {:fg (w 0) :bg (w 93)})
	(set-hl :LeapLabelPrimary {:bg purple}))

;  :CursorLine  
;  :QuickFixLine  
;  :Substitute  
;  :TabLineSel  
;  :TermCursor 0
;  :TermCursorNC  
;  :VisualNOS  
;  :WildMenu  
;  :LspReferenceText  
;  :LspReferenceRead  
;  :LspReferenceWrite  
;  :

