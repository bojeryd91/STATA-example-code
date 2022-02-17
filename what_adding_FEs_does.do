
/*
	Example 1 illustrates how time FEs can reduce standard errors.
	Below we simulate data where in every period t there is a 
	shifter (time_FEs) that affects the outcomes of every group
	(group_ID) in that period. Half of all group_IDs are treated,
	and in the post period (t > 3) the treated have an outcome that
	is raised/lowered by treatXpost_effect.
	The effect can be correctly estimated even if we do not include
	period dummies in the regression, but the standard errors are
	greater because of the misspecification. */

cap log close
log using "./what_adding_FEs_does.log", replace
*** Simulate data
clear
set obs 100
gen group_ID    = _n
gen treat_dummy = _n > _N/2

expand 2
bysort group_ID: gen post = _n

expand 3
bysort group_ID (post): gen t = _n

scalar sd_eps = 0.001
gen error = sd_eps*rnormal()

bysort t: gen tmp = rnormal() if _n == 1
by     t: gegen time_FEs = max(tmp)
drop tmp

gen treatment_effect  = 1
gen treatXpost_effect = 2
gen post_dummy = t > 3
gen treatXpost_dummy = treat_dummy*post_dummy
gen outcome = treatXpost_effect*treatXpost_dummy + ///
					treatment_effect*treat_dummy + time_FEs + error

*** Summarize the data
tabstat outcome time_FEs, by(t) stat(mean)
tabstat outcome time_FEs if treat_dummy == 0, by(t) stat(mean)
tabstat outcome time_FEs treatment_effect treatXpost_effect ///
		if treat_dummy == 1, by(t) stat(mean)
					
*** Analysis part. First, run regression with the correct specification
reg outcome treatXpost_dummy treat_dummy i.t

**  Note also how the time FEs aren't correctly estimated. Each dummy is
*		off by the amount of the intercept. _cons in turn is equal to the
*		omitted dummy for period t = 1. The omission is due to collinearity
*		and the intercept is taken out of each non-omitted dummy.
tabstat time_FEs, by(t)

*** Then, compare std. err. of treatXpost_dummy if we don't include time
*		fixed effects but instead a post dummy
reg outcome treatXpost_dummy treat_dummy post_dummy


*** Case of no time_FEs but a post effect
gen post_effect = -0.5*post_dummy 
replace outcome = outcome - time_FEs + post_effect
reg outcome treatXpost_dummy treat_dummy post_dummy
*   Then the std. err. of treatXpost_dummy is small as in the correctly
*		specified case
log close