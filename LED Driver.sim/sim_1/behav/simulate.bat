@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.2\\bin
call %xv_path%/xsim LedDriver_tb_behav -key {Behavioral:sim_1:Functional:LedDriver_tb} -tclbatch LedDriver_tb.tcl -view D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.srcs/sim_1/imports/LED Driver/LedDriver_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
