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
ExecStep $xv_path/bin/xelab -wto 530871d8df9b4ec782bef9f370d79e38 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot tb_top_behav xil_defaultlib.tb_top xil_defaultlib.glbl -log elaborate.log
