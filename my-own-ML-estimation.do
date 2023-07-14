/*
	Just illustrating and expanding on the example from
	https://www.stata.com/features/overview/maximum-likelihood-estimation/

*/
clear
sysuse auto.dta

*	Using built-in estimator
logit foreign mpg weight

*	Defining my own
cap program drop mylogit
program define mylogit
          args lnf Xb
          quietly replace `lnf' = -ln(1+exp(-`Xb')) if $ML_y1==1
          quietly replace `lnf' = -`Xb' - ln(1+exp(-`Xb')) if $ML_y1==0
end

keep foreign mpg weight
ml model lf mylogit (foreign=mpg weight)
ml maximize
ds

*	Defining my own
cap program drop mylogit2
program define mylogit2
    args lnf Xb		// what goes into `lnf' seems to be determined by the 
	disp "`lnf'"	// ml command. Could be renamed
    qui replace `lnf' = 	  - ln(1+exp(-`Xb')) if $ML_y1==1 // $ML_y1 is the outcome
    qui replace `lnf' = -`Xb' - ln(1+exp(-`Xb')) if $ML_y1==0
end

ml model lf mylogit2 (foreign=mpg weight)
ml maximize