#!/bin/sh
#
# Compile and run the test bench

[ -x "$(command -v iverilog)" ] || { echo "Install iverilog"; exit 1; }

rm -f cpu_tb.log
echo "======================================================================================"
echo "                                  Behavioral Simulation                               "
echo "======================================================================================"
echo "Ensure all required files listed in program_files_behav.txt"
echo ""

echo "Compiling sources"
iverilog  -o cpu_tb -c program_file_behav.txt
if [ $? != 0 ]; then
    echo "*** Compilation error! Please fix."
    exit 1;
fi
./cpu_tb

retval=$(grep -c FAIL cpu_tb.log)
if [ $retval -eq 0 ];
then
    echo "Passed"
    echo ""
else
    echo "Failed Behavioral Simulation"
    exit 1
fi

echo "======================================================================================"
echo "                         Synthesis & Post-Synthesis Simulation                        "
echo "======================================================================================"
echo "Ensure all required files listed in program_files_synth.txt"
echo "Ensure that 'synth.ys' lists all the modules needed for the synthesis,"
echo "and that the top module is called 'cpu'"
echo ""

./genSynthTcl.sh . > synth.tcl

# Run Yosys to synthesize
yosys synth.ys > yosysLog_default.txt

if [ $? != 0 ]; then
    echo "Synthesis failed.  Please check for error messages."
    exit 1;
fi

rm -f cpu_tb.log
echo "Compiling sources for post-synthesis simulation"

iverilog  -o cpu_tb -c program_file_synth.txt
if [ $? != 0 ]; then
    echo "*** Compilation error! Please fix."
    exit 1;
fi
./cpu_tb

retval=$(grep -c FAIL cpu_tb.log)
if [ $retval -eq 0 ];
then
    echo "Passed"
    echo ""
else
    echo "Failed Post-Synthesis simulation"
    exit 1
fi

cat << EOF
You should see a PASS message and all tests pass.
If any test reports as a FAIL, fix it before submitting.
Once all tests pass, commit the changes into your code,
and push the commit back to the server for evaluation.
EOF

exit $retval
