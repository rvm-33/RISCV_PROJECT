#!/bin/bash -f
xv_path="/home/Xilinx/SDSoC/2015.4/Vivado/2015.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim tb_top_behav -key {Behavioral:sim_1:Functional:tb_top} -tclbatch tb_top.tcl -view /home/l210/work/ec23b1029/RISCV_PROJECT/ec23b1029/dct_test.wcfg -log simulate.log
