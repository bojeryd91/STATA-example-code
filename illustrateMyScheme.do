graph drop _all
webuse union, clear

collapse (mean) age grade, by(year)

twoway	(line age year)   ///
		(line grade year), name("default") ///
		title("A title!") xtitle("Title on the x axis")
		
pwd		
set scheme myScheme
graph set window fontface "Times New Roman"

twoway	(line age year)   ///
		(line grade year), name("fancy") ///
		title("A title!") xtitle("Title on the x axis")