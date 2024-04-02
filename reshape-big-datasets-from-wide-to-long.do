/*
	This do-files illustrates a pattern to reshape/transpose big datasets
	which the built-in reshape (or, also the excellent command greshape)
	struggle with due to memory issues.
	
	The pattern is to subset the data into blocks. Keep N_block observations,
	reshape them, set aside, and then reshape next block. Repeat for all blocks
	and then append the separate blocks into one big file.
	
	
*/

clear

scalar N_block = 1000 // Set the size of the block to reshape

*** Generate example data that is wide
set obs 10000
gen ID = _n

forval year = 1/100 {
	gen val_in_`year' = `year' + runiform()
}

tempfile sample
save "`sample'"

*** Perform the reshape
qui count
scalar N_obs = `r(N)'
forval n = 1(`=N_block')`=N_obs' {
	* Backup all the rows that haven't been reshaped yet and then keep only
	* the block of rows to reshape in this iteration
	preserve
	keep if _n < N_block
	
	* Perform the reshape
	reshape long val_in_, i(ID) j(year)
	
	* Save it in a temp file
	tempfile temp`n'
	save `temp`n''
	
	* Bring back the rows that were backed up and drop the lines that were
	* reshaped above. Then return to the top of the loop and repeat.
	restore
	drop if _n < N_block
}

*	Append the individual blocks back into the final file
clear
forval n = 1(`=N_block')`=N_obs' {
	append using "`temp`n''"
}

// Done!

******************************************************************************
*** Compare output to the built-in version
tempfile result
save "`result'"

use "`sample'"
reshape long val_in_, i(ID) j(year)
rename val_in_ val_in_orig

merge 1:1 ID year using "`result'"
rename val_in_ val_in_alt

gen diff = val_in_orig - val_in_alt
sum diff