clear all
set more off
capture ssc install outreg2

use "project3.dta", clear

* 1. Data preparation
capture drop age
generate age = exper + edu + 6

capture drop log_wage
generate log_wage = ln(wage + 1)

capture drop exper_sq
generate exper_sq = exper^2

capture drop edu_urban
generate edu_urban = edu * urban

* 2. Model 1: baseline linear model of hourly wage
* age is excluded because age = exper + edu + 6 (perfect multicollinearity)
regress wage edu i.gender i.married i.public exper i.urban i.region

display "--- VIF ---"
vif

display "--- Ramsey RESET ---"
ovtest

display "--- Breusch-Pagan ---"
hettest

* Heteroskedasticity detected: re-estimate with robust standard errors
regress wage edu i.gender i.married i.public exper i.urban i.region, vce(robust)
outreg2 using "project3_results.doc", replace se dec(3) ctitle(Model 1 - Linear) word label

* 3. Model 2: gender x public sector interaction
regress log_wage edu i.married exper i.urban i.region i.gender##i.public, vce(robust)
outreg2 using "project3_results.doc", append se dec(3) ctitle(Model 2 - Gender x Public) word label

* 4. Model 3: returns to education in urban vs rural areas
regress log_wage c.edu##i.urban i.gender i.married i.public exper i.region, vce(robust)
outreg2 using "project3_results.doc", append se dec(3) ctitle(Model 3 - Edu x Urban) word label

display "--- Test: edu x urban = 0 ---"
test 1.urban#c.edu = 0

* 5. Model 4: quadratic experience profile
regress log_wage edu i.gender i.married i.public c.exper##c.exper i.urban i.region, vce(robust)
outreg2 using "project3_results.doc", append se dec(3) ctitle(Model 4 - Quadratic) word label

display "Experience at peak wage: " -_b[exper] / (2 * _b[c.exper#c.exper])

* 6. Predicted log wage by years of experience
margins, at(exper=(0(1)50))
marginsplot, noci ///
    title("Non-linear Relationship between Experience and Log Wages") ///
    xtitle("Years of Experience") ///
    ytitle("Predicted Log Hourly Wage")
graph export "project3_exper_quadratic.png", replace
