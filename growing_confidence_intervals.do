clear

set seed 04292023
set obs 21

gen event_time = -11 + _n

expand 5000

gen t_w_shock = event_time == 0

gen t = _n
sort t

gen outcome = 1*t_w_shock + 0.25*rnormal()
tab event_time

qui sum event_time if event_time != .
gen ee_time = event_time - `r(min)' + 1
reg outcome ib10.ee_time if event_time != .

drop outcome
gen outcome = 0 if _n == 1
replace outcome = outcome[_n-1] + 1.0*t_w_shock + 0.1*rnormal() if _n > 1

gen t2 = t^2
gen t3 = t^3
gen t4 = t^4
reg outcome ib10.ee_time t* if event_time != .