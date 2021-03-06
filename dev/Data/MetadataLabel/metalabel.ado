** Labels Variables from Metadata

cap prog drop metalabel
prog def metalabel

syntax using, [varlab] [vallab]

preserve

import excel `using', first clear
	
* Prepare variable labels if specified.

	if "`varlab'" != "" {

		qui count
		forvalues i = 1/`r(N)' {
			local theVarname = varname[`i']
			local `theVarname'_lab = varlab[`i']
			}
			
		}
			
* Prepare value labels if specified

	if "`vallab'" != "" {
			
	* Prepare list of value labels needed.
		
		drop if `vallab' == ""
	
		cap duplicates drop `vallab', force
		
		count
			if `r(N)' == 1 {
				local theValueLabels = `vallab'[1]
				}
			else {
				forvalues i = 1/`r(N)' {
					local theNextValLab  = `vallab'[`i']
					local theValueLabels `theValueLabels' `theNextValLab'
					}
				}
			
	* Prepare list of values for each value label.
			
		import excel `using', first clear sheet(vallab)
			tempfile valuelabels
				save `valuelabels', replace
					
		foreach theValueLabel in `theValueLabels' {
			use `valuelabels', clear
			keep if name == "`theValueLabel'"
			local theLabelList "`theValueLabel'"
				count
				local n_vallabs = `r(N)'
				forvalues i = 1/`n_vallabs' {
					local theNextValue = value[`i']
					local theNextLabel = label[`i']
					local theLabelList_`theValueLabel' `" `theLabelList_`theValueLabel'' `theNextValue' "`theNextLabel'" "'
					}
			}
				
	* Prepare parallel lists of variables to be value-labeled and their corresponding value labels.
				
		import excel `using', first clear
				
			keep if `vallab' != ""
			local theValueLabelNames ""
			
			count
				if `r(N)' == 1 {
					local theVarNames	 = varname[1]
					local theValueLabelNames = `vallab'[1]
					}
				else {
					forvalues i = 1/`r(N)' {
						local theNextVarname  = varname[`i']
						local theNextValLab   = `vallab'[`i']
						local theVarNames `theVarNames' `theNextVarname'
						local theValueLabelNames `theValueLabelNames' `theNextValLab'
						}
					}
								
	} // End vallab option.
	
* Apply to master.
	
restore

	foreach var of varlist * {
		if "``var'_lab'" != "" label var `var' "``var'_lab'"
		}
		
	if "`vallab'" != "" {
		
		foreach theValueLabel in `theValueLabels' {
			label def `theValueLabel' `theLabelList_`theValueLabel''
			}
				
			destring `theVarNames', replace
		
			local n_labels : word count `theValueLabelNames'
			if `n_labels' == 1 {
				label val `theVarNames' `theValueLabelNames'
				}
			else {
				forvalues i = 1/`n_labels' {
					local theNextVarname : word `i' of `theVarNames'
					local theNextValLab  : word `i' of `theValueLabelNames'
					label val `theNextVarname' `theNextValLab'
					}
				}
				
		} // End vallab option
		
end
