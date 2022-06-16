clear

******************************************************************************
*** Set sample sizes, etc.
scalar num_teachers = 40
scalar num_students = num_teachers*30
scalar num_years    = 3
scalar effect_of_experience = 0.2
scalar mean_teacher_effect = 1

set seed 05222022

******************************************************************************
*** Create a teacher dataset
set obs `=num_teachers'
gen teacher_ID = _n

gen     teacher_effect = mean_teacher_effect + rnormal() if teacher_ID != .
replace teacher_effect = 0.5 if teacher_effect < 0.5 & teacher_ID != .
*	Above is just to add some funky feature to data

**	Add effect of experience
gen teacher_experience = rbinomial(6, 0.3)
tab teacher_experience

expand num_years
bysort teacher_ID: g year = _n

replace teacher_experience = teacher_experience - 1 + year

gen teacher_effect_w_experience = teacher_effect + ///
										effect_of_experience*teacher_experience

tempfile teachers
save `teachers'

******************************************************************************
*** Create set of students
clear
set obs `=num_students'
gen student_ID = _n

gen     student_effect = 2 + rnormal()
replace student_effect = 0.1 if student_effect < 0.1
*	Above is a normative statement that student's aren't worse than zero ;)

**	Create each year per student
expand `=num_years'
bysort student_ID: g year = _n

*	Add year effect
bysort year: gen  temp_year_effect = rnormal() if _n == 1
by     year: egen      year_effect = max(temp_year_effect)
drop temp_year_effect

*** Assign each student-year a teacher
*   Shuffle students-years
gen random = runiform()
sort random

*   Make assignment
egen teacher_ID = seq(), t(1) f(`=num_teachers')

**  Merge on teacher effects
merge m:1 teacher_ID year using `teachers'
tab teacher_ID // See that each teacher appears the right number of times

*** Create outcome variable with noise
gen grade = student_effect + teacher_effect_w_experience + year_effect + 0.3*rnormal()

******************************************************************************
*** Estimate teacher effects
xtset student_ID year
reghdfe grade l.grade /*teacher_experience*/, absorb(teacher_ID year, savefe)
* teacher_experience is actually omitted b/c of collinearity when we have
*	year FEs

*	SAVE GAMMA
sort teacher_ID
gen est_teacher_effect = __hdfe1__ // __hdfe2__ is year FEs, see ordering in absorb()

keep teacher_ID teacher_effect est_teacher_effect
drop if est_teacher_effect == . // note that year 1 is missing b/c of lagged grade
duplicates drop
count

*** We get the rankings right, but the estimates are off by the mean teacher
*	effect which was specified at the top
twoway  (scatter teacher_effect est_teacher_effect) ///
		(line    teacher_effect teacher_effect)
		
gen est_teacher_effect_alt = est_teacher_effect + mean_teacher_effect
twoway  (scatter teacher_effect est_teacher_effect_alt) ///
		(line    teacher_effect teacher_effect)
		
pwcorr teacher_effect est_teacher_effect est_teacher_effect_alt