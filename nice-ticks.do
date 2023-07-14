/*

*/

clear
set obs 24

gen yq = `=tq(2009q4)' + _n
format %tqCY!Qq yq // get better formatting on year-quarter

tab yq

gen outcome = rnormal()

scatter outcome yq, /// not what I want
	name("graph1", replace)

qui sum yq
scatter outcome yq, ///
	xlabel(`=r(min)'(4)`=r(max)-1') name("graph2", replace)