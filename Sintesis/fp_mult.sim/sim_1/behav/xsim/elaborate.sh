#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2018.1 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Tue Apr 22 02:30:26 -03 2025
# SW Build 2188600 on Wed Apr  4 18:39:19 MDT 2018
#
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
#
# usage: elaborate.sh
#
# ****************************************************************************
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep xelab -wto 47af8528f4774b0b9944e209b7163d09 --incr --debug typical --relax --mt 8 -L xil_defaultlib -L secureip -L xpm --snapshot fp_multiplier_VIO_behav xil_defaultlib.fp_multiplier_VIO -log elaborate.log
