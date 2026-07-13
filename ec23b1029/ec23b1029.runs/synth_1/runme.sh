#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/Xilinx/SDSoC/2015.4/SDK/2015.4/bin:/home/Xilinx/SDSoC/2015.4/Vivado/2015.4/ids_lite/ISE/bin/lin64:/home/Xilinx/SDSoC/2015.4/Vivado/2015.4/bin
else
  PATH=/home/Xilinx/SDSoC/2015.4/SDK/2015.4/bin:/home/Xilinx/SDSoC/2015.4/Vivado/2015.4/ids_lite/ISE/bin/lin64:/home/Xilinx/SDSoC/2015.4/Vivado/2015.4/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/home/Xilinx/SDSoC/2015.4/Vivado/2015.4/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/home/Xilinx/SDSoC/2015.4/Vivado/2015.4/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/l210/work/ec23b1029/RISCV_PROJECT/ec23b1029/ec23b1029.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log top.vds -m64 -mode batch -messageDb vivado.pb -notrace -source top.tcl
