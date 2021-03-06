# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config -id {Synth 8-256} -limit 10000
set_msg_config -id {Synth 8-638} -limit 10000
set_msg_config  -ruleid {1}  -id {Synth 8-5788}  -suppress 
create_project -in_memory -part xc7a15tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir {D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.cache/wt} [current_project]
set_property parent.project_path {D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.xpr} [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
read_verilog {{D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.srcs/sources_1/new/gamma_LUT.vh}}
set_property file_type "Verilog Header" [get_files {{D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.srcs/sources_1/new/gamma_LUT.vh}}]
read_mem {{D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.srcs/sources_1/new/DefaultPixels.mem}}
read_verilog -library xil_defaultlib {
  {D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.srcs/sources_1/new/pll.v}
  {D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.srcs/sources_1/new/dpram.v}
  {D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.srcs/sources_1/new/LedDriver.v}
  {D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.srcs/sources_1/new/FillMemory.v}
  {D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.srcs/sources_1/new/Main.v}
  {D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.srcs/sources_1/new/spi_handler.v}
  {D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.srcs/sources_1/imports/new/spi.v}
  {D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/LED Driver.srcs/sources_1/new/BackBufferHandler.v}
}
foreach dcp [get_files -quiet -all *.dcp] {
  set_property used_in_implementation false $dcp
}
read_xdc {{D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/TE0725.xdc}}
set_property used_in_implementation false [get_files {{D:/Repositories/FPGA/Xilinx/Vivado/LED Driver/TE0725.xdc}}]


synth_design -top Main -part xc7a15tcsg324-1


write_checkpoint -force -noxdef Main.dcp

catch { report_utilization -file Main_utilization_synth.rpt -pb Main_utilization_synth.pb }
