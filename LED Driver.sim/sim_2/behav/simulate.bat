@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.2\\bin
call %xv_path%/xsim pll_tb_behav -key {Behavioral:sim_2:Functional:pll_tb} -tclbatch pll_tb.tcl -view D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/pll_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
