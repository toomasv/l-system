Red [
	Author: "Toomas Vooglaid"
	Date: 25-9-2017
	Description: {Experiments with L-System}
	Last-update: 28-9-2017
	Needs: %models.red
]
context [
	ctx: self
	
	scale: origin: length: len: angle: width: delta-width: times-length: none
	delta-length: delta-len: delta-angle: anti-aliasing?: stack: commands: none
	_L: _U: _X: _Origin: _Scale: _Length: _Angle: _Len: _Width: _Delta-width: none
	_Delta-length: _Delta-len: _Times-length: _Delta-angle: _Anti-aliasing?: none
	_Models: _Matrix: _Zoom: str1: str: iter: lang: win: scl: none
	
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
	set-opts: func [opts /local word value][
		stack: copy [] commands: copy []
		foreach [word value] self/defaults [self/:word: value]
		put drawing #"+" [rotate (negate angle)]
		put drawing #"-" [rotate (angle)]
		opts: compose opts 
		foreach [word value] opts [self/:word: value]
	]
	expand: func [str iter /local elem][
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
	make-commands: func [str iter /local symb cmd][
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
			line-join round
			_Matrix: matrix [(scl) 0 0 (negate scl) (origin/x) (origin/y)]
		]
	]
	set-fields: func [model /local char lang vals][
		forall chars [
			put self/(to-word rejoin ["_" chars/1]) 'text either lang: select model/language chars/1 [lang][none]
		]
		set-opts model/options
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
		set-opts reduce field-options
		language: reduce [#"L" _L/text] 
		unless empty? _U/text [append language reduce [#"U" _U/text]]
		unless empty? _X/text [append language reduce [#"X" _X/text]]
		make-commands expand _Initial/text _Iterations/data _Iterations/data
		_Img/draw: commands
	]
	set-opts models/1/options 
	iter: models/1/iterations
	language: models/1/language
	str1: expand str: models/1/initial models/1/iterations
	make-commands str1 models/1/iterations
	make-models: func [/selected sel /local drop][
		drop: copy [] forall models [append drop models/1/title] 
		_Models/data: drop
		either selected [
			_Models/selected: sel
		][
			if _Models/selected > length? models [_Models/selected: 1]
		]
		set-fields pick models _Models/selected 
		show-current
	]
	diff_: down?_: pos_: change_: ev: dr: df: dr+: dr-: df+: df-: none
	win: view/no-wait compose/deep [
		title "L-system playground"
		tab-panel [
			"Graphics" [
				group-box "Options" [
					style label: text middle right
					label "Origin:" 50 _Origin: field 65 (to-string origin) 
					label "Width:" 50 _Width: field 65 (to-string width) 
					label "Length:" 55 _Length: field 65 (to-string length) 
					label "Len:" 50 _Len: field 65 (to-string len) 
					label "Angle:" 50 _Angle: field 65 (to-string angle) 
					return 
					label "Scale:" 50 _Scale: field 65 (to-string scale)
					label "D-width:" 50 _Delta-width: field 65 (to-string delta-width) 
					label "D-Length:" 55 _Delta-length: field 65 (to-string delta-length) 
					label "D-Len:" 50 _Delta-len: field 65 (to-string delta-len)
					label "D-angle:" 50 _Delta-angle: field 65 (to-string delta-angle) 
					return
					label "L:" 15 _L: field 146 hint "Rule for L" (select language #"L")
					label "U:" 15 _U: field 147 hint "Rule for U" (either U: select language #"U" [U][""])
					label "X:" 15 _X: field 147 hint "Rule for X" (either X: select language #"X" [X][""])
					label "T-length:" 50 _Times-length: field 65 (to-string times-length) 
					return 
					label "Model:" 40 _Models: drop-list data [
						(drop: copy [] forall models [append drop models/1/title] drop)
					] select 1 on-change [
						set-fields pick models face/selected
						show-current
						_Zoom/data: scl
					]
					label "Initial:" 35 _Initial: field 100 (to-string str) 
					label "Iterations:" 55 _Iterations: field 20 (to-string iter) pad 5x0
					_Anti-aliasing?: check "Anti-alias" data (anti-aliasing?) pad 15x0
					button "<" 25 [
						_Iterations/data: _Iterations/data - 1
						show-current
						_Zoom/data: scl
					]
					button ">" 25 [
						_Iterations/data: _Iterations/data + 1
						show-current
						_Zoom/data: scl
					]
					button "Show" 65 [
						show-current
						_Zoom/data: scl
					] 
				]
				_Zoom: slider 20x174 data (scl) [
					;on-create: func [face [object!]][
					;	on-change face none
					;]
					on-change: func [face [object!] event [event! none!]][
						if scale < iter [_Scale/data: round/to face/data * iter 0.01]
						_Matrix/2/1: face/data
						_Matrix/2/4: negate face/data
					]
				]
				return
				_Img: image (size) 
				draw [(commands)]
				all-over
				on-down [diff_: event/offset - _Origin/data down?_: yes]
				on-up [down?_: no _Origin/data: pos_]
				on-over [
					if down?_ [
						change_: _Origin/data - event/offset + diff_
						pos_: _Origin/data - change_ 
						_Matrix/2/5: pos_/x _Matrix/2/6: pos_/y
					]
				]
				on-wheel [
					ev: event/offset - face/offset - face/parent/offset - face/parent/parent/offset - face/parent/parent/parent/offset
					dr:	to-pair reduce [_Matrix/2/5 _Matrix/2/6]
					df: dr - ev
					df+: to-pair reduce [to-integer df/x / 1.1 to-integer df/y / 1.1]
					df-: to-pair reduce [to-integer df/x * 1.1 to-integer df/y * 1.1]
					dr+: df+ + ev
					dr-: df- + ev
					_Matrix/2: reduce [
						either 0 > event/picked [_Matrix/2/1 / 1.1][_Matrix/2/1 * 1.1]
						0 0
						either 0 > event/picked [_Matrix/2/4 / 1.1][_Matrix/2/4 * 1.1]
						either 0 > event/picked [dr+/x][dr-/x]
						either 0 > event/picked [dr+/y][dr-/y]
					]
				]
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
	win/menu: [
		"Save (^S)" save  
		"Add ... (^A)" add 
		"Delete (^D)" delete 
		"Reload (^S)" reload 
		"Save image ... (^I)" save-image
	]
	save-models: has [model production][
		model: pick models _Models/selected
		language: copy []
		forall chars [
			if not empty? production: copy select ctx/(to-word rejoin ["_" chars/1]) 'text [
				append language reduce [chars/1 production]
			]
		]
		model/language: language 
		model/initial: copy _Initial/text
		model/iterations: _Iterations/data
		model/options: reduce field-options
		write %models.red models
	]
	add-model: has [save? new-language new-model production _New][
		view/flags [
			title "Add model"
			_New: field 133 hint "Model name:" return 
			button "OK" [save?: yes unview] 
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
			append models new-model
			make-models/selected length? models
		]
	]
	image-save: has [save? _New][
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
	delete-model: does [
		remove at models _Models/selected
		make-models
	]
	reload-models: does [
		models: load %models.red
		make-models
	]
	win/actors: object [
		on-menu: func [face event][
			switch event/picked [
				save [save-models]
				add [add-model]
				delete [delete-model]
				reload [reload-models]
				save-image [image-save]
			]
		]
		on-key: func [face event][
			if event/flags = [control] [
				switch event/key [
					#"^S" [save-models]
					#"^A" [add-model]
					#"^D" [delete-model]
					#"^R" [reload-models]
					#"^-" [image-save]
				]
			]
		]
	]
	win
]
