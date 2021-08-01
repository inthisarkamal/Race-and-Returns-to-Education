****Begin with opening the 2004 5th grade test scores dataset****

use "/Users/inthisarkamal/Downloads/ecls_5th_grade.dta"
drop pct_minority
drop bmi
drop problem_turnover
drop problem_attacks
drop has_library_card

ssc install outreg2
ssc install asdoc 

gen read = reading_test
gen math = math_test


gen crowding = problem_crowding
gen drugs = problem_drugs
gen gangs = problem_gangs
gen crime = problem_crime
gen weapons = problem_weapons


drop science_test

label var read "5th grade Reading Score"
label var math "5th grade Math Score"

gen extracurricular_total = part_dance + part_athletics + part_club + part_music + part_art
su extracurricular_total

gen any_extracurricular = .
replace any_extracurricular = 1 if part_dance == 1 | part_athletics == 1 | part_club == 1  | part_music == 1 |  part_art == 1 
su any_extracurricular
tab extracurricular_total 
tab any_extracurricular


gen public_school =.
replace public_school = 1 if school_type ==1
replace public_school = 0 if school_type == 2 | school_type == 3

gen private_school =.
replace private_school=1 if school_type == 3
replace private_school = 0 if school_type ==1 | school_type ==2

gen mommarried = .
replace mommarried = 1 if mom_curr_married ==1
replace mommarried = 0 if mom_curr_married ==0

gen total_testscore = read + math 

label define race_vals 1 "White" 2 "Black" 3 "Hispanic" 4 "Other"
label values race race_vals


gen White = race == 1
gen Black = race == 2
gen Hispanic = race == 3
gen Other = race == 4

label define school_type_vals 1 "Public School" 2 "Catholic School" 3 "Private School" 
label values school_type school_type_vals


gen mom_college = mom_educ == 4
label define mom_educ_vals 4 "Mom went to College"
label values mom_educ mom_educ_vals


gen dance = part_dance
gen athletics = part_athletics
gen club = part_club
gen music = part_music
gen art = part_art

***Running descriptive statistics***
asdoc summarize family_income siblings hhsize read math


tabstat read math, statistics(mean, sd, min max)
tabstat math, stat(mean, sd, min max)
tabstat read math, stat(mean, p25, p50, p75, min max)

asdoc sum math, detail
asdoc sum read, detail

tab race, summarize (math)
tab race, summarize (read)

****Run summary statistics to determine any relationships between test scores and extra-curricular activities****



corr total_testscore extracurricular_total



corr total_testscore athletics
corr total_testscore club
corr total_testscore dance
corr total_testscore music
corr total_testscore art 


****Run summary statistics to determine relationships between income and extra curricular activities****


corr family_income any_extracurricular
corr family_income athletics
corr family_income club
corr family_income dance
corr family_income music
corr family_income art 

****Run summary statistics to determine relationship between family background/school type and math and reading test scores****

corr total_testscore race
corr total_testscore school_type
corr total_testscore mom_educ 


asdoc corr family_income total_testscore extracurricular_total public_school private_school White Black Hispanic mommarried mom_educ, replace



****Run a regression analysis on reading and math test scores and import to word****


reg read White Black Hispanic extracurricular_total tv_* problem_* public_school private_school mom_college mommarried
outreg2 using regression_results, replace word
reg math White Black Hispanic extracurricular_total tv_* problem_* public_school private_school mom_college mommarried
outreg2 using regression_results, append word

****Save the new 5th grade dataset****

save "/Users/inthisarkamal/Downloads/ecls_5th_grade.dta", replace



clear


****Bring in new dataset, "Returns to College (Female)"*****

use "/Users/inthisarkamal/Downloads/march_cps_females.dta"
sort year

****Append with dataset "Returns to College (Male)"****

append using "/Users/inthisarkamal/Downloads/march_cps_males.dta"
sort year
keep if year == 2004

****Clean dataset****

drop veteran
gen hrsworked_per_week = uhrswork
gen weeks_worked_2003 = wkswork1


gen race = race4
label define race_vals 1 "white" 2 "black" 3 "other" 4 "hispanic"
label values race race_vals
tab race
label define marital_status_vals 1 "married" 2 "divorced/separated" 3 "widowed" 4 "unmarried"
label values marital_status marital_status_vals
tab marital_status

gen parents_married =.
replace parents_married = 1 if marital_status == 1
replace parents_married = 0 if marital_status == 2| marital_status == 4


gen white = race == 1
gen black = race == 2
gen hispanic = race == 4
gen other = race == 3


***Create table to tabulate number of college graduates by race in 2004***

asdoc tabulate race college_grad, column
asdoc tabulate race college_grad, row


****Run regression college_grad****
asdoc corr college_grad white black hispanic parents_married weekly_earn hourly_wage, replace
asdoc reg weekly_earn white black hispanic college_grad

***Merge with new dataset of 5th grade test scores***

merge m:m race using "/Users/inthisarkamal/Downloads/ecls_5th_grade.dta"


***Running a loop***

foreach y in "reg" "logit" "probit" {
`y' college_grad mom_educ
}


foreach x of varlist part_* {
summ `x'
}

****Determine relationship between graduating from college and 5th grade reading and math scores****

corr college_grad math 
corr college_grad read

****Determine relationship between probability of graduating from college and attending a private school in the fifth grade****


asdoc corr college_grad private_school

***Summary statistics with the merged data***

summarize hrsworked_per_week weekly_earn family_income


graph bar (count) college_grad, over(race)

graph save "Graph" "/Users/inthisarkamal/Downloads/Data Visualization.gph"



asdoc describe, replace






save "/Users/inthisarkamal/Downloads/Final final dataset.dta"






