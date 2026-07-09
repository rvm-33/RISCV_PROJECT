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
ExecStep $xv_path/bin/xsim tb_vector_datapath_behav -key {Behavioral:sim_1:Functional:tb_vector_datapath} -tclbatch tb_vector_datapath.tcl -log simulate.log
