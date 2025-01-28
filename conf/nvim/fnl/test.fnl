;; test

(fn new-que [] {:item [] :first 1 :last 0})

(fn que-size [que] (+ 1 (- que.last que.first)))

(fn que-empty? [que] (< (que-size que) 1))

(fn push-que [que value] 
  (let [last (+ 1 que.last)]
	(tset que :last last)
	(tset que :item last value))
  que)

(fn peek-que [que] 
  (if (que-empty? que)
	  nil
	  (. que.item que.first)))

(fn pop-que [que] 
  (if (que-empty? que)
	  que
	  (let [value (. que.item que.first)]
		(tset que.item que.first nil)
		(set que.first (+ que.first 1))
		que)))


(-> que (peek-que))
