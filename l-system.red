Red [
	Author: "Toomas Vooglaid"
	Date: 25-9-2017
	Description: {Experiments with L-System}
	Last-update: 27-9-2017
	Needs: %models.red
]
context [
	ctx: self
	
	scale: origin: length: len: angle: width: delta-width: times-length: none
	delta-length: delta-len: delta-angle: anti-aliasing?: stack: commands: none
	_L: _U: _X: _Origin: _Scale: _Length: _Angle: _Len: _Width: _Delta-width: none
	_Delta-length: _Delta-len: _Times-length: _Delta-angle: _Anti-aliasing?: none
	_Models: str1: str: iter: lang: win: none
	
	models: load %models.red
	chars: [#"L" #"U" #"X"]
	size: 700x600
	
	defaults: [
		scale 	2.0
		origin 	300x500
		length 	0x100
		len 	100
		angle 	90
		width 	1
		delta-width 	1
		times-length 	2
		delta-length 	0x10
		delta-len		10
		delta-angle 	15
		anti-aliasing?	yes
	]
	drawing: [
		#"U" [line 0x0 (length) translate (length)]
		#"L" [line 0x0 (length) translate (length)]
		#"M" [translate (length)]
		#"l" ['line (length)]
		#"h" ['hline (len)]
		#"v" ['vline (len)]
		#"m" ['move (length)]
		#"+" [rotate (negate angle)]
		#"-" [rotate (angle)]
		#"|" [rotate 180]
		#"&" [swap next find drawing #"+" next find drawing #"-"]
		;#"[" []
		;#"]" []
		;#"{" []
		;#"}" []
		#"#" [line-width (width: width + delta-width)]
		#"!" [line-width (width: width - delta-width)]
		#"@" [circle 0x0 (width)]
		#">" [length: length * times-length len: len * times-length]
		#"<" [length: length / times-length len: len / times-length]
		#"(" [angle: angle - delta-angle]
		#")" [angle: angle + delta-angle]
		#"´" [length: length + delta-length len: len + delta-len]
		#"`" [length: length - delta-length len: len - delta-len]
	]
	set-opts: func [opts iter /local word value][
		stack: copy [] commands: copy []
		foreach [word value] self/defaults [self/:word: value]
		put drawing #"+" [rotate (negate angle)]
		put drawing #"-" [rotate (angle)]
		if opts [opts: compose opts foreach [word value] opts [self/:word: value]]
	]
	expand: func [str iter][
		either iter > 0 [
			str: loop iter [
				str: rejoin parse/case str compose [
					collect some [
						set elem skip 
						if (find extract language 2 elem) 
							keep (select language elem) 
					| 	keep skip
					]	
				]
			]
		][str]
	]
	make-commands: func [str iter /local symb cmd scl][
		length: either iter > 0 [length / (2 * iter)][length] 
		parse str [some [
				set symb [#"<" | #">" | #"&" | #"(" | #")" | #"´" | #"`"] (do select drawing symb)
			|	[#"[" | #"{"] (insert/only stack commands commands: copy []) 
			|	set symb [#"]"| #"}"] (
					commands: either empty? commands [
						take stack
					][
						switch symb [
							#"]" [append append/only append take stack 'push copy commands [pen black]]
							#"}" [append/only append take stack 'shape head insert copy commands [move 0x0]]
						]
					]
				)
			|	set symb skip (append commands compose/deep either cmd: select drawing symb [cmd][[]])
		]]
		scl: either iter > 0 [scale / iter][1]
		insert commands compose/deep [
			anti-alias (either anti-aliasing? ['on]['off]) 
			line-width (width)
			matrix [(scl) 0 0 (negate scl) (origin/x) (origin/y)]
		]
	]
	set-fields: func [model /local char lang vals][
		forall chars [
			put self/(to-word rejoin ["_" chars/1]) 'text either lang: select model/language chars/1 [lang][""]
		]
		set-opts model/options model/iterations
		vals: extract defaults 2
		forall vals [
			put self/(to-word rejoin ["_" vals/1]) 'data get vals/1 
		]
		_Initial/text: model/initial
		_Iterations/data: model/iterations
	]
	field-options: [
		'origin _Origin/data 'scale _Scale/data 'length _Length/data 
		'angle _Angle/data 'len _Len/data 'width _Width/data 'delta-width _Delta-width/data 
		'delta-length _Delta-length/data 'delta-len _Delta-len/data 
		'times-length _Times-length/data 'delta-angle _Delta-angle/data
		'anti-aliasing? to-paren reduce [_Anti-aliasing?/data]
	]
	show-current: does [
		set-opts reduce field-options _Iterations/data
		language: reduce [#"L" _L/text] 
		unless empty? _U/text [append language reduce [#"U" _U/text]]
		unless empty? _X/text [append language reduce [#"X" _X/text]]
		make-commands expand _Initial/text _Iterations/data _Iterations/data
		_Img/draw: commands
	]
	set-opts models/1/options iter: models/1/iterations
	language: models/1/language
	str1: expand str: models/1/initial models/1/iterations
	make-commands str1 models/1/iterations
	;make-models: function [drop: copy [] forall models [append drop models/1/title] drop]
	win: view/no-wait compose/deep [
		title "L-system playground"
		tab-panel [
			"Graphics" [
				group-box "Options" [
					text "Origin:" 50 _Origin: field 65 (to-string origin) 
					text "Width:" 50 _Width: field 65 (to-string width) 
					text "Length:" 55 _Length: field 65 (to-string length) 
					text "Len:" 50 _Len: field 65 (to-string len) 
					text "Angle:" 50 _Angle: field 65 (to-string angle) 
					return 
					text "Scale:" 50 _Scale: field 65 (to-string scale)
					text "D-width:" 50 _Delta-width: field 65 (to-string delta-width) 
					text "D-Length:" 55 _Delta-length: field 65 (to-string delta-length) 
					text "D-Len:" 50 _Delta-len: field 65 (to-string delta-len)
					text "D-angle:" 50 _Delta-angle: field 65 (to-string delta-angle) 
					return
					text "L:" 15 _L: field 146 hint "Rule for L" (select language #"L")
					text "U:" 15 _U: field 147 hint "Rule for U" (either U: select language #"U" [U][""])
					text "X:" 15 _X: field 147 hint "Rule for X" (either X: select language #"X" [X][""])
					text "T-length:" 50 _Times-length: field 65 (to-string times-length) 
					return 
					text "Model:" 40 _Models: drop-list data [(drop: copy [] forall models [append drop models/1/title] drop)] select 1 on-change [
						set-fields pick models face/selected
						show-current
					]
					text "Initial:" 35 _Initial: field 100 (to-string str) 
					text "Iterations:" 55 _Iterations: field 20 (to-string iter) pad 5x0
					_Anti-aliasing?: check "Anti-alias" data (anti-aliasing?) pad 7x0
					button "<" 25 [
						_Iterations/data: _Iterations/data - 1
						show-current
					]
					button ">" 25 [
						_Iterations/data: _Iterations/data + 1
						show-current
					]
					button "Show" 65 [show-current] 
				]
				return
				_Img: image (size) 
				draw [(commands)]
			]
			"Instructions" [space 10x5 
					text "X"  20 text "For controlling repetition patterns only. Not directly drawn." return
					text "L"  20 text "Inserts a line with dimensions of `length` and moves turtle to the end of this line." return
					text "U"  20 text "Same as U. Needed for different repetition patterns in language." return
					text "M"  20 text "Moves turtle by dimensions of `length`." return
					text "l"  20 text "Draws line of `length` dimensions in shape and moves turtle to the end of this line." return
					text "h"  20 text "Draws horizontal line of length `len` in shape block and moves to the end of the line." return
					text "v"  20 text "Draws vertical line of length `len` in shape block and moves to the end of the line." return
					text "m"  20 text "Moves turtle in shape block by `length`." return
					text "+"  20 text "Rotates head of the turtle by `angle` degrees to right." return
					text "-"  20 text "Rotates head of the turtle by `angle` degrees to left." return
					text "|"  20 text "Rotates head of the turtle by 180 degrees." return
					text "&&" 20 text "Swaps directions of `+` and `-`." return
					text "["  20 text "Opens `push` block" return
					text "]"  20 text "Closese `push` block" return
					text "{"  20 text "Opens `shape` block" return
					text "}"  20 text "Closese `shape` block" return
					text "#"  20 text "Increases line-width by `delta-width`." return
					text "!"  20 text "Decreases line-width by `delta-width`." return
					text "@"  20 text "Draws circle with radius of `width`." return
					text ">"  20 text "Increases `length` and `len` `times-length` times." return
					text "<"  20 text "Decreases `length` and `len` `times-length` times." return
					text ")"  20 text "Increases angle by `delta-angle`." return
					text "("  20 text "Decreases angle by `delta-angle`." return
					text "´"  20 text "Increases `length` and `len` by `delta-length`." return
					text "`"  20 text "Decreases `length` and `len` by `delta-length`." return
			]
		]
	]
	set-fields pick models 1
	win/menu: ["Save" save  "Save as ..." save-as "Save image ..." save-image "Delete" delete "Reload" reload]
	win/actors: object [
		on-menu: func [face event /local model _New save? production sel drop][
			switch event/picked [
				save [
					model: pick models _Models/selected 
					model/options: reduce field-options
					write %models.red models
				]
				save-as [
					view/flags [
						title "Save as ..."
						_New: field 133 hint "Model name:" return 
						button "Save" [save?: yes unview] 
						button "Cancel" [save?: no unview]
					][modal popup]
					if save? [
						new-language: copy []
						forall chars [
							if not empty? production: copy select ctx/(to-word rejoin ["_" chars/1]) 'text [
								append new-language reduce [chars/1 production]
							]
						]
						new-model: make map! compose/deep [
						    title (_New/text)
							language [(new-language)]
							initial (copy _Initial/text)
							iterations (_Iterations/data)
							options [(reduce field-options)]
						]
						probe append models new-model
						write %models.red models
						drop: copy [] forall models [append drop models/1/title] 
						_Models/data: drop
						_Models/selected: length? models
						set-fields pick models _Models/selected 
						show-current
					]
				]
				save-image [
					;write file: request-file/filter/save [
					;	"Image Files" "*.png" "All" "*.*"
					;] draw size _Img/draw
					view/flags [
						title "Save image"
						_New: field 133 data ".png" return 
						button "Save" [save?: yes unview] 
						button "Cancel" [save?: no unview]
					][modal popup]
					if save? [
						save to-file _New/text draw size _Img/draw
					]
				]
				delete [
					remove at models _Models/selected
					if _Models/selected > length? models [_Models/selected: 1]
					drop: copy [] forall models [append drop models/1/title] 
					_Models/data: drop
					set-fields pick models _Models/selected 
					show-current
				]
				reload [
					models: load %models.red
					;	set-opts models/1/options iter: models/1/iterations
					;	language: models/1/language
					;	str1: expand str: models/1/initial models/1/iterations
					;	make-commands str1 models/1/iterations
					drop: copy [] forall models [append drop models/1/title] 
					_Models/data: drop
					set-fields models/1
					show-current
				]
			]
		]
	]
	win
]
