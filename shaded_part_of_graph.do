/*
	This script shows an example how to use scatteri and a second y axis
	to shade a region in a graph.
*/

webuse union, clear

collapse (mean) age grade, by(year)

twoway	(connected age   year)                     ///
		(connected grade year)                     ///
		(scatteri 500 72.5 500 75.25,              ///
			bcolor(gs10%30) lwidth(none)           ///
			recast(area) yaxis(2)),                ///
		legend(order(1 "Mean age" 2 "Mean grade")) ///
		yscale(axis(2) r(0 1) off)
		
/*
 	scatteri creates points for the band from 72.5 to 75.25 horizontally.
	bcolor adjusts the color and transparency
	lwidth(none) removes the default border of the rectangle
	recast(area) turn the points into the band we want
	yaxis(2) puts the graph on its own graph. THIS IS IMPORTANT: if you want
		to use two vertical axes and this code, you have to put the band
		on yet another yaxis
	legend() is manually specified so that the band does not show up in the
		legend.
	yscale(axis(2) r(0 1) off) : r(0 1) set the range to be 0--1 (uses full
		height of graph in a nice-looking way).
		The "off" hides the right axis scale.
*/