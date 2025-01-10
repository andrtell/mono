(local themes [:blue :darkblue :delek :desert 
			   :elflord :evening :industry :koehler 
			   :morning :murphy :pablo :peachpuff 
			   :ron :shine :slate :torte 
			   :quiet :zellner])

{1 "zaldih/themery.nvim"
 :lazy false
 :config (fn []
		   (let [themery (require :themery)]
			 (themery.setup {:livePreview true
							 :themes themes})))}
