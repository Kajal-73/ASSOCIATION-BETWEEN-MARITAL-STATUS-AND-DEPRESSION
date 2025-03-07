********************************
* Intermediate Epi Spring 2024
* Project : Complete Code For Analysis 
* Date   : April 20, 2024
* Author : Kajal Gupta
* Professor : Emily Goldmann
********************************

**# Code for Analysis Project

**# Setting up: set directory and merge datasets
* clear stata
clear 
* Specify file path to the location where you have saved the dataset 
cd "/Users/kajalgupta/Desktop/Intermediate Epi"

* Merge data
use "Depression_data for ANALYSIS PROJECT.dta", clear
browse
sum seqn
use "NHANES_Dataset for ANALYSIS PROJECT.dta", clear
browse
sum seqn 
sort seqn
// Merging second dataset using unique ID(seqn)
merge 1:1 seqn using "Depression_data for ANALYSIS PROJECT.dta"
sum seqn
* Set all variable names to lowercase
rename *, lower 
* Use "codebook" to see codebook information on variables in dataset 
codebook 

* set eligibility
gen eligible = ridageyr >=20 & ridageyr<=65 & !mi(dpq010, dpq020, dpq030, dpq040, dpq050, dpq060, dpq070, dpq080, dpq090)
tab eligible
drop if eligible == 0
*(9,483 observations deleted)
tab eligible

save "Analytical Project.dta",replace

**# Data Cleaning
use "Analytical Project.dta", clear
* Gender
label define genderlabel 1 "Male" 2 "Female"
label values riagendr genderlabel
rename riagendr gender
tab gender, missing

* Age (years)
summarize ridageyr  // For mean , standard deviation  also range 
summarize ridageyr, detail // For Interquartile Range , median

* Race/Ethnicity
label define race_label 1 "Mexican American" 2 "Other Hispanic" 3 "Non-Hispanic White" 4 "Non-Hispanic Black" 6 "Non-Hispanic Asian" 7 "Other Race - Including Multi-Racial"
label values ridreth3 race_label
rename ridreth3 race
tab race, missing

* just for better interpretability we classified the race variable into 3 categories . 
gen race_ethinicity = race
replace race_ethinicity = 1 if race_ethinicity == 1 | race_ethinicity== 2
replace race_ethinicity = 2 if race_ethinicity == 3 | race_ethinicity == 4 | race_ethinicity == 6
replace race_ethinicity= 3 if race_ethinicity == 7
label define race_ethinicity_labels 1 "Hispanic" 2 "Non-Hispanic" 3 "Other"
label values race_ethinicity race_ethinicity_labels
tab race_ethinicity, missing
* the two should match (tab ridreth3 and tab race).


*INDFMPIR (Ratio of family income to poverty)
* Ratio of Family Income to Poverty
tab indfmpir,missing
* Categorizing and Labelling Accordingly 
recode indfmpir (0/1.99=1) (2/3.99=2) (4/max=3) 
label define indfmpir_labels 1 "Low IPR (0 - 1.99)" 2 "Medium IPR (2.0 - 3.99)" 3 "High IPR (>= 4.0)" 
label values indfmpir indfmpir_labels
tab indfmpir, missing 
codebook indfmpir
* For better interpretation , classified into categories which was mentioned earlier in Part C.


* Exposure of Interest
* dmdmartz (Marital Status)
* label Marital Status categories
***
label define maritallabel 1 "Married/Living with Partner" 2 "Widowed/Divorced/Separated" 3 "Never Married" 77 "Refused" 99"Don't know"
label values dmdmartz maritallabel
tab dmdmartz, missing
* recoding 77 & 99 to missing values
gen marital_status = dmdmartz
replace marital_status = 1 if marital_status == 1 // Married/Living with Partner
replace marital_status = 2 if marital_status == 2 // Widowed/Divorced/Separated
replace marital_status = 3 if marital_status == 3 // Never Married
replace marital_status=. if marital_status == 77 // Refused
replace marital_status=. if marital_status == 99 // Don't know
label values marital_status maritallabel
tab marital_status, missing
****

* Outcome of interest
*Depression(continous)
*recoding 7 & 9 to missing values
gen dep_1= dpq010
replace dep_1=. if dpq010==7 | dpq010==9
gen dep_2= dpq020
replace dep_2=. if dpq020==7 | dpq020==9
gen dep_3= dpq030
replace dep_3=. if dpq030==7 | dpq030==9
gen dep_4= dpq040
replace dep_4=. if dpq040==7 | dpq040==9
gen dep_5= dpq050
replace dep_5=. if dpq050==7 | dpq050==9
gen dep_6= dpq060
replace dep_6=. if dpq060==7 | dpq060==9
gen dep_7= dpq070
replace dep_7=. if dpq070==7 | dpq070==9
gen dep_8= dpq080
replace dep_8=. if dpq080==7 | dpq080==9
gen dep_9= dpq090
replace dep_9=. if dpq090==7 | dpq090==9

*Define depression labels
label define dep_compiled_label 0 "Not at all" 1 "Several days" 2 "More than half the days" 3 "Nearly every day" 7 " Refused" 9 "Don't know"
* label depression variable categories
label values dpq010 dpq020 dpq030 dpq040 dpq050 dpq060 dpq070 dpq080 dpq090 dep_compiled_label
* generate variable to tally depression score
gen dep_compiled= dep_1+dep_2+dep_3+dep_4+dep_5+dep_6+dep_7+dep_8+dep_9
summarize dep_compiled, detail
tab dep_compiled, missing


*Depression(categorical)
* Code depression into categories based on tallied score 
gen depression_cate = dep_compiled
replace depression_cate = 0 if dep_compiled < 10
replace depression_cate = 1 if dep_compiled >= 10
label define depression_cate_labels 0 "Not Depressed(<10)" 1 "Depressed(>=10)" 
label values depression_cate depression_cate_labels
tab depression_cate, missing


save "Analysis Data_cleaned.dta",replace

**# Univariable Analysis
**************************
** Table 1
**************************
*# POTENTIAL CONFOUNDING VARIABLES
***# Gender
tab gender, missing

***# Age (years)
summarize ridageyr, detail

***# Race/Ethinicity
tab race_ethinicity, missing

*# POTENTIAL EFFECT MEASUE MODIFIER VARIABLE   
***# Ratio of family income to poverty ratio
tab indfmpir, missing 

*# MAIN EXPOSURE OF INTEREST 
***# MARITAL STATUS
tab marital_status, missing
					  
*# MAIN OUTCOME 
***# DEPRESSION(categorical)					  
tab depression_cate, missing

***# DEPRESSION(continous)	
summarize dep_compiled, detail
			 
**# Plots for continuous variables 
* Age (years)
histogram ridageyr,normal discrete title("Normal Distribution of Age at Screening")

* Depression (continous)
histogram dep_compiled,normal discrete  title("Normal Distribution of Depression Score")

**# Bivariable Analysis
**************************
** Table 2
**************************
*# POTENTIAL CONFOUNDING VARIABLES
***# Gender and Marital Status (categorical , categorical)
tab gender marital_status  , chi2 
tab gender marital_status , col

***# Age(years) and Marital Status (continous, categorical)
anova ridageyr marital_status
sum ridageyr if marital_status == 1,detail
sum ridageyr if marital_status == 2,detail
sum ridageyr if marital_status == 3,detail

***# Race/Hispanic Origin w/ NH Asian and Marital Status(categorical, categorical)
tab race_ethinicity marital_status, chi2 
tab race_ethinicity marital_status, col

 *# POTENTIAL EFFECT MEASUE MODIFIER VARIABLE  
***# Ratio of Family Income to Poverty and Marital Status (categorical, categorical)
tab indfmpir marital_status, chi2 
tab indfmpir marital_status, col

*# MAIN OUTCOME					  
***# Depression Categorical and Marital Status (categorical, categorical)
tab depression_cate marital_status, chi2 
tab depression_cate marital_status, col

***# Depression Continous and Marital Status (continous, categorical)
anova  dep_compiled marital_status
sum dep_compiled if marital_status == 1, detail
sum dep_compiled if marital_status == 2, detail
sum dep_compiled if marital_status == 3, detail

**************************
** Table 3.a
**************************
*# POTENTIAL CONFOUNDING VARIABLES
***# Gender and Depression Categorical (categorical , categorical)
tab gender depression_cate , chi2 
tab gender depression_cate, col

***# Age(years) and Depression Categorical (continous, categorical)
anova ridageyr depression_cate
sum ridageyr if depression_cate == 0, detail
sum ridageyr if depression_cate == 1, detail

***# Race/Hispanic Origin w/ NH Asian  and Depression Categoricals(categorical, categorical)
tab race_ethinicity depression_cate, chi2 
tab race_ethinicity depression_cate,col

*# POTENTIAL EFFECT MEASUE MODIFIER VARIABLE  			 
***# Ratio of Family Income to Poverty and Depression Categorical (categorical, categorical)
tab indfmpir depression_cate, chi2 
tab indfmpir depression_cate, col
      
 *# MAIN EXPOSURE OF INTEREST 
***# Marital Status and Depression Categorical (categorical, categorical)
tab marital_status depression_cate, chi2 
tab marital_status depression_cate, col

**************************
** Table 3.b
**************************
*# POTENTIAL CONFOUNDING VARIABLES
***# Gender and Depression Continous (categorical , continous)
anova gender dep_compiled
sum dep_compiled if gender == 1,detail
sum dep_compiled if gender == 2,detail

***# Age(years) and Depression Continous (continous, continous)
pwcorr ridageyr dep_compiled,sig
**0R
spearman ridageyr dep_compiled ,stats(rho p)

***# Race/Hispanic Origin w/ NH Asian  and Depression Continous(categorical, continous)
anova race_ethinicity dep_compiled
sum dep_compiled if race_ethinicity == 1,detail
sum dep_compiled if race_ethinicity == 2,detail
sum dep_compiled if race_ethinicity == 3,detail

*# POTENTIAL EFFECT MEASUE MODIFIER VARIABLE  
***# Ratio of Family Income to Poverty and Depression Continous (categorical, continous)
anova indfmpir dep_compiled
sum dep_compiled if indfmpir == 1,detail
sum dep_compiled if indfmpir == 2,detail
sum dep_compiled if indfmpir == 3,detail
                      
*# MAIN EXPOSURE OF INTEREST
***# Marital Status and Depression Continous (categorical, continous)
anova marital_status dep_compiled
sum dep_compiled if marital_status == 1,detail
sum dep_compiled if marital_status == 2,detail
sum dep_compiled if marital_status == 3,detail
                        

**# Multivariable Analysis
**************************
** Table 4.a
**************************
***# LOGISTIC REGRESSION 

*# POTENTIAL CONFOUNDING VARIABLES 
*# Gender
logistic depression_cate i.gender
* MALE : refrence category

*# Age (years)
logistic depression_cate ridageyr

*# Race/Ethinicity
logistic depression_cate ib3.race_ethinicity
* Other : refrence category

*# POTENTIAL EFFECT MEASUE MODIFIER VARIABLE 
*# Ratio of Family Income to Poverty
logistic depression_cate i.indfmpir
* LOW IPR : refrence category

*# MAIN EXPOSURE OF INTEREST
*# Marital Status
logistic depression_cate i.marital_status
* Married/Cohabitating : refrence category

** Full Model 1:
logistic depression_cate i.gender ridageyr ib3.race_ethinicity i.indfmpir i.marital_status 


** Full Model 2:
logistic depression_cate i.gender ridageyr ib3.race_ethinicity ib1.indfmpir i.marital_status##i.indfmpir


**************************
** Table 4.b
**************************
***# LINEAR REGRESSION 

*# POTENTIAL CONFOUNDING VARIABLES 
*# Gender
regress dep_compiled i.gender
* MALE : refrence category

 *# Age (years)
regress dep_compiled ridageyr

*# Race/Ethinicity
regress dep_compiled ib3.race_ethinicity
* Other : refrence category

*# POTENTIAL EFFECT MEASUE MODIFIER VARIABLE 
*# Ratio of Family Income to Poverty
regress dep_compiled i.indfmpir
* LOW IPR : refrence category

*# MAIN EXPOSURE OF INTEREST
*# Marital Status
regress dep_compiled i.marital_status
* Married/Cohabitating : refrence category

** Full Model 1:
regress dep_compiled i.gender ridageyr ib3.race_ethinicity i.indfmpir i.marital_status 
 
** Full Model 2:
regress dep_compiled i.gender ridageyr ib3.race_ethinicity ib1.indfmpir i.marital_status##i.indfmpir
     
     
