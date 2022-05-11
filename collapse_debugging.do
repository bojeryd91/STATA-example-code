*** Generate random data
set seed 05102022
clear
set obs 1000000
gen ID = _n

expand 5
bysort ID: g period = _n

expand 5
bysort ID period: g category = _n

gen var1 = rnormal()
gen var2 = rnormal()

save "temp_file", replace

use  "temp_file", clear
*** Now, Stata uses 685.8 MB RAM

*** Collapse
forval i = 1/6 {
	disp "Collapse no. `i'"
	collapse (sum) var1 var2, by(ID period category)
}
save "temp_file2", replace
*** At this point, Stata uses 3,198.9 MB RAM
clear all
*** At this point, Stata still uses 2,384.3 MB RAM
use  "temp_file2"
*** At this point, Stata uses 3,114.6 MB RAM
*** But if I close Stata, restart, and load only line 30 it uses 792.3 MB RAM 