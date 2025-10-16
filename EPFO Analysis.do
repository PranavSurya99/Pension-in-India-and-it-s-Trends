//Importing and Cleaning Data//

import excel "data.xls", sheet("Sheet1") firstrow clear
rename Year year
rename NoofPensionersBenefited pensioners
rename AmountPaidasOriginalPension original_pension
rename AmountPaidasperMinimumPensionNotification minimum_pension
rename DifferenceAmount difference
gen fiscal_year = substr(year, 1, 4) if strpos(year, "-")
replace fiscal_year = "2023" if year == "2023-2024-upto December 2023"
replace fiscal_year = "2024" if year == "2024-upto March (Projections)"
destring fiscal_year, replace
misstable summarize

// Calculating the Trends/
sort fiscal_year
tsset fiscal_year
gen pensioners_growth = (pensioners - L.pensioners) / L.pensioners * 100
gen min_pension_growth = (minimum_pension - L.minimum_pension) / L.minimum_pension * 100
gen difference_growth = (difference - L.difference) / L.difference * 100
tabstat pensioners_growth min_pension_growth difference_growth, statistics(mean min max) by(fiscal_year)

// Inflation Adjustment//
gen cpi = .
replace cpi = 140 in 1 // 2018-2019
replace cpi = 151 in 2 // 2019-2020
replace cpi = 158 in 3 // 2020-2021
replace cpi = 169 in 4 // 2021-2022
replace cpi = 181 in 5 // 2022-2023
replace cpi = 193 in 6 // 2023-2024
replace cpi = 197 in 7 // Q1 2024
gen real_pension = (1000 / cpi) * (140 / 100) * 100

//Estimate ₹7,500 Pension Cost//
gen cost_7500 = pensioners * 7500 * 12 / 10000000 // ₹ Crore
sum cost_7500 if fiscal_year == 2023


// Data visualization//

**Line**
line pensioners fiscal_year, title("EPFO Minimum Pension Beneficiaries (2018-2024)") ytitle("Pensioners") xtitle("Fiscal Year")
graph export "pensioners_line.png", replace

**Bar Chart( Disbursements)**
graph bar (mean) original_pension minimum_pension difference, over(fiscal_year) title("EPFO Pension Disbursements (2018-2024)") ytitle("Amount (₹ Crore)") legend(label(1 "Original") label(2 "Minimum") label(3 "Difference"))
graph export "pension_bar.png", replace



// Saving and Exporting the Files//
save "pension_analysis.dta", replace
export delimited fiscal_year pensioners original_pension minimum_pension difference pensioners_growth min_pension_growth difference_growth real_pension cost_7500 using "pension_data.csv", replace


******************************************************