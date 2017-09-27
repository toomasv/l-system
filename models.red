#(	
	title: "Blocky 1"
	language: [#"L" "L+L-L-LL+L+L-L"]
	initial: "L+L+L+L" 
	iterations: 3 
	options: [angle 90 length 0x100 scale 1.0 origin 200x470 anti-aliasing? (false)]
)
#(
	title: "Blocky 2"
	language: [#"L" "LL+L-L+L+LL"] ; FF-F+F-F-FF
	initial: "L+L+L+L" 
	iterations: 4 
	options: [angle 90 length 100x0 scale 2.0 origin 200x300 anti-aliasing? (false)]
)
#(
	title: "Weed 1"
	language: [
		#"L" "LL"
		#"X" "L-[[X]+X]+L[+LX]-X" ;F-[[X]+X]+F[+FX]-X
	]
	initial: "X" 
	iterations: 6 
	options: [angle 22.5 length 30x100 scale 2.0 origin 300x570]
)
#(	title: "Weed 2"
	language: [
		#"L" "LL"
		#"X" "L-[[X]-X]+L[-LX]-X" ;F-[[X]+X]+F[+FX]-X
	]
	initial: "&X" 
	iterations: 6 
	options: [angle 22.5 length 30x100 scale 2.0 origin 300x570]
)
#(
	title: "Weed 3"
	language: [#"U" "L[+U]-U" #"L" "LL"]
	initial: "U" 
	iterations: 7 
	options: [angle 45 length 0x100 scale 3.0 origin 350x580 anti-aliasing? (false)]
)
#(
	title: "Koch curve"
	language: [#"L" "L-L+L+L-L"] 
	initial: "+L" 
	iterations: 3 
	options: [angle 90 origin 150x380 anti-aliasing? (false)]
)
#(
	title: "Sierpinski triangle"
	language: [#"L" "L-U+L+U-L" #"U" "UU"] 
	initial: "L-U-U" 
	iterations: 6 
	options: [length 100x0 angle 120 origin 50x580 scale 6.0]
)
#(
	title: "Spiral"
	language: [#"L" "L+U" #"U" "´L+U"] 
	initial: "L" 
	iterations: 5 
	options: [origin 350x300 scale 4.0 anti-aliasing? (false)]
)
