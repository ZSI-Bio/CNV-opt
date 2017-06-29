
#!/bin/bash

# source the unit test for scripts functions
. jshutest.inc

#functions to test
. ../math.sh


bcTest() {

        result=$(bc_func 2 2)
        if [ $result -eq 4 ] ; then
                return ${jshuPASS}
        fi
	return ${jshuFAIL}	
}



# initialize testsuite
jshuInit

# run unit tests on script
jshuRunTests

# result summary
jshuFinalize

echo Done.
echo
let tot=failed+errors
exit $tot
