* Simple STATA command definition
cap program drop testProgram
program define testProgram, rclass
    syntax namelist [if], [an_option(string)]

    gettoken input1 0 : 0
    gettoken input2 0 : 0
    gettoken input3 0 : 0, parse(", ") // split by comma or space

    disp "1: `input1', 2: `input2', 3: `input3'"
    if "`an_option'" != "" {
        disp "Option provided: `an_option'!"
    }
	
	if "`input3'" != "" {
		sum `input3' `if', detail // use an qualifier
	}
	
	* Put stuff in r()
	return local output_in_r = "`input1'"
end

* Examplify
sysuse auto, clear

testProgram hello world

testProgram hello world length, an_option("whaaat?")

testProgram hello world length if foreign == 1
disp "`r(output_in_r)'"