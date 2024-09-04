/*
	This script illustrates the bias in the example of basketball players.
	"Height helps when playing basketball. But conditional on being in the
	NBA, height does not predict performance"
*/
clear
cls

set obs 1000000

gen talent = rnormal(175, 100)
gen height = rpoisson(175)

gen measured_skill = 2.0*talent + 1.5*height + rnormal()

_pctile measured_skill, p(99.95)
gen in_NBA = measured_skill > `r(r1)'

sum talent if in_NBA == 1
sum height if in_NBA == 1

reg measured_skill height
reg measured_skill height if in_NBA == 1

reg measured_skill talent height if in_NBA == 1

