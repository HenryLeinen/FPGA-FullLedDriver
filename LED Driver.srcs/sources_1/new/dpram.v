
module dpram (
                input               clk100,
                input               rst_n,

                input               backbuffer,

//  Port a is used from the led driver module to only read from the frontbuffer 
//  This is typically done by the led driver itself. 
                input    [9:0]      rd_addr_front_buffer,
                output  [15:0]      rd_data_front_buffer_upper,
                output  [15:0]      rd_data_front_buffer_lower,
                
//  Port b is used from the CPU or memory filling logic and only writes and reads to/from the backbuffer
//  Read and write access is word wise and the memory is exported in a linear way.
                input   [10:0]      addr_b,
                inout   [15:0]      data_b,
                input               wr_ena
             );
             
    wire    [15:0]      data_hi_b;
    wire    [15:0]      data_lo_b;
    

/*
XPM_MEMORY instantiation template for true dual port RAM configurations
Refer to the targeted device family architecture libraries guide for XPM_MEMORY documentation
=======================================================================================================================

Parameter usage table, organized as follows:
+---------------------------------------------------------------------------------------------------------------------+
| Parameter name       | Data type          | Restrictions, if applicable                                             |
|---------------------------------------------------------------------------------------------------------------------|
| Description                                                                                                         |
+---------------------------------------------------------------------------------------------------------------------+
+---------------------------------------------------------------------------------------------------------------------+
| MEMORY_SIZE          | Integer            | Must be integer multiple of [WRITE|READ]_DATA_WIDTH_[A|B]               |
|---------------------------------------------------------------------------------------------------------------------|
| Specify the total memory array size, in bits.                                                                       |
| For example, enter 65536 for a 2kx32 RAM.                                                                           |
+---------------------------------------------------------------------------------------------------------------------+
| MEMORY_PRIMITIVE     | String             | Must be "auto", "distributed", "block" or "ultra"                       |
|---------------------------------------------------------------------------------------------------------------------|
| Designate the memory primitive (resource type) to use:                                                              |
|   "auto": Allow Vivado Synthesis to choose                                                                          |
|   "distributed": Distributed memory                                                                                 |
|   "block": Block memory                                                                                             |
|   "ultra": Ultra RAM memory                                                                                         |
+---------------------------------------------------------------------------------------------------------------------+
| CLOCKING_MODE        | String             | Must be "common_clock" or "independent_clock"                           |
|---------------------------------------------------------------------------------------------------------------------|
| Designate whether port A and port B are clocked with a common clock or with independent clocks:                     |
|   "common_clock": Common clocking; clock both port A and port B with clka                                           |
|   "independent_clock": Independent clocking; clock port A with clka and port B with clkb                            |
+---------------------------------------------------------------------------------------------------------------------+
| MEMORY_INIT_FILE     | String             | Must be exactly "none" or the name of the file (in quotes)              |
|---------------------------------------------------------------------------------------------------------------------|
| Specify "none" (including quotes) for no memory initialization, or specify the name of a memory initialization file:|
|   Enter only the name of the file with .mem extension, including quotes but without path (e.g. "my_file.mem").      |
|   File format must be ASCII and consist of only hexadecimal values organized into the specified depth by            |
|   narrowest data width generic value of the memory.  See the Memory File (MEM) section for more                     |
|   information on the syntax. Initialization of memory happens through the file name specified only when parameter   |
|   MEMORY_INIT_PARAM value is equal to "".                                                                           |                                                                                        |
|   When using XPM_MEMORY in a project, add the specified file to the Vivado project as a design source.              |
+---------------------------------------------------------------------------------------------------------------------+
| MEMORY_INIT_PARAM   | String             | Must be exactly "" or the string of hex characters (in quotes)           |
|---------------------------------------------------------------------------------------------------------------------|
| Specify "" or "0" (including quotes) for no memory initialization through parameter, or specify the string          | 
| containing the hex characters.Enter only hex characters and each location separated by delimiter(,).                |
| Parameter format must be ASCII and consist of only hexadecimal values organized into the specified depth by         |
| narrowest data width generic value of the memory.  For example, if the narrowest data width is 8, and the depth of  |
| memory is 8 locations, then the parameter value should be passed as shown below.                                    |
|   parameter MEMORY_INIT_PARAM = "AB,CD,EF,1,2,34,56,78"                                                             |
|                                  |                   |                                                              |
|                                  0th                7th                                                             |
|                                location            location                                                         |
+---------------------------------------------------------------------------------------------------------------------+
| USE_MEM_INIT         | Integer             | Must be 0 or 1                                                         |
|---------------------------------------------------------------------------------------------------------------------|
| Specify 1 to enable the generation of below message and 0 to disable the generation of below message completely.    |
| Note: This message gets generated only when there is no Memory Initialization specified either through file or      |
| Parameter.                                                                                                          |
|    INFO : MEMORY_INIT_FILE and MEMORY_INIT_PARAM together specifies no memory initialization.                       |
|    Initial memory contents will be all 0's                                                                          |
+---------------------------------------------------------------------------------------------------------------------+
| WAKEUP_TIME          | String             | Must be "disable_sleep" or "use_sleep_pin"                              |
|---------------------------------------------------------------------------------------------------------------------|
| Specify "disable_sleep" to disable dynamic power saving option, and specify "use_sleep_pin" to enable the           |
| dynamic power saving option                                                                                         |
+---------------------------------------------------------------------------------------------------------------------+
| MESSAGE_CONTROL      | Integer            | Must be 0 or 1                                                          |
|---------------------------------------------------------------------------------------------------------------------|
| Specify 1 to enable the dynamic message reporting such as collision warnings, and 0 to disable the message reporting|
+---------------------------------------------------------------------------------------------------------------------+
| WRITE_DATA_WIDTH_A   | Integer            | Must be > 0 and equal to the value of READ_DATA_WIDTH_A                 |
|---------------------------------------------------------------------------------------------------------------------|
| Specify the width of the port A write data input port dina, in bits.                                                |
| The values of WRITE_DATA_WIDTH_A and READ_DATA_WIDTH_A must be equal.                                               |
+---------------------------------------------------------------------------------------------------------------------+
| READ_DATA_WIDTH_A    | Integer            | Must be > 0 and equal to the value of WRITE_DATA_WIDTH_A                |
|---------------------------------------------------------------------------------------------------------------------|
| Specify the width of the port A read data output port douta, in bits.                                               |
| The values of READ_DATA_WIDTH_A and WRITE_DATA_WIDTH_A must be equal.                                               |
+---------------------------------------------------------------------------------------------------------------------+
| BYTE_WRITE_WIDTH_A   | Integer            | Must be 8, 9, or the value of WRITE_DATA_WIDTH_A                        |
|---------------------------------------------------------------------------------------------------------------------|
| To enable byte-wide writes on port A, specify the byte width, in bits:                                              |
|   8: 8-bit byte-wide writes, legal when WRITE_DATA_WIDTH_A is an integer multiple of 8                              |
|   9: 9-bit byte-wide writes, legal when WRITE_DATA_WIDTH_A is an integer multiple of 9                              |
| Or to enable word-wide writes on port A, specify the same value as for WRITE_DATA_WIDTH_A.                          |
+---------------------------------------------------------------------------------------------------------------------+
| ADDR_WIDTH_A         | Integer            | Must be >= ceiling of log2(MEMORY_SIZE/[WRITE|READ]_DATA_WIDTH_A)       |
|---------------------------------------------------------------------------------------------------------------------|
| Specify the width of the port A address port addra, in bits.                                                        |
| Must be large enough to access the entire memory from port A, i.e. >= $clog2(MEMORY_SIZE/[WRITE|READ]_DATA_WIDTH_A).|
+---------------------------------------------------------------------------------------------------------------------+
| READ_RESET_VALUE_A   | String             |                                                                         |
|---------------------------------------------------------------------------------------------------------------------|
| Specify the reset value of the port A final output register stage in response to rsta input port is assertion.      |
+---------------------------------------------------------------------------------------------------------------------+
| READ_LATENCY_A       | Integer             | Must be >= 0 for distributed memory, or >= 1 for block memory          |
|---------------------------------------------------------------------------------------------------------------------|
| Specify the number of register stages in the port A read data pipeline. Read data output to port douta takes this   |
| number of clka cycles.                                                                                              |
| To target block memory, a value of 1 or larger is required: 1 causes use of memory latch only; 2 causes use of      |
| output register. To target distributed memory, a value of 0 or larger is required: 0 indicates combinatorial output.|
| Values larger than 2 synthesize additional flip-flops that are not retimed into memory primitives.                  |
+---------------------------------------------------------------------------------------------------------------------+
| WRITE_MODE_A         | String             | Must be "write_first", "read_first", or "no_change".                    |
|                                           | For distributed memory, must be read_first.                             |
|---------------------------------------------------------------------------------------------------------------------|
| Designate the write mode of port A:                                                                                 |
|   "write_first": Write-first write mode                                                                             |
|   "read_first" : Read-first write mode                                                                              |
|   "no_change"  : No-change write mode                                                                               |
| Distributed memory configurations require read-first write mode.                                                    |
+---------------------------------------------------------------------------------------------------------------------+
| WRITE_DATA_WIDTH_B   | Integer            | Must be > 0 and equal to the value of READ_DATA_WIDTH_B                 |
|---------------------------------------------------------------------------------------------------------------------|
| Specify the width of the port B write data input port dinb, in bits.                                                |
| The values of WRITE_DATA_WIDTH_B and READ_DATA_WIDTH_B must be equal.                                               |
+---------------------------------------------------------------------------------------------------------------------+
| READ_DATA_WIDTH_B    | Integer            | Must be > 0 and equal to the value of WRITE_DATA_WIDTH_B                |
|---------------------------------------------------------------------------------------------------------------------|
| Specify the width of the port B read data output port doutb, in bits.                                               |
| The values of READ_DATA_WIDTH_B and WRITE_DATA_WIDTH_B must be equal.                                               |
+---------------------------------------------------------------------------------------------------------------------+
| BYTE_WRITE_WIDTH_B   | Integer            | Must be 8, 9, or the value of WRITE_DATA_WIDTH_B                        |
|---------------------------------------------------------------------------------------------------------------------|
| To enable byte-wide writes on port B, specify the byte width, in bits:                                              |
|   8: 8-bit byte-wide writes, legal when WRITE_DATA_WIDTH_B is an integer multiple of 8                              |
|   9: 9-bit byte-wide writes, legal when WRITE_DATA_WIDTH_B is an integer multiple of 9                              |
| Or to enable word-wide writes on port B, specify the same value as for WRITE_DATA_WIDTH_B.                          |
+---------------------------------------------------------------------------------------------------------------------+
| ADDR_WIDTH_B         | Integer            | Must be >= ceiling of log2(MEMORY_SIZE/[WRITE|READ]_DATA_WIDTH_B)       |
|---------------------------------------------------------------------------------------------------------------------|
| Specify the width of the port B address port addrb, in bits.                                                        |
| Must be large enough to access the entire memory from port B, i.e. >= $clog2(MEMORY_SIZE/[WRITE|READ]_DATA_WIDTH_B).|
+---------------------------------------------------------------------------------------------------------------------+
| READ_RESET_VALUE_B   | String             |                                                                         |
|---------------------------------------------------------------------------------------------------------------------|
| Specify the reset value of the port B final output register stage in response to rstb input port is assertion.      |
+---------------------------------------------------------------------------------------------------------------------+
| READ_LATENCY_B       | Integer             | Must be >= 0 for distributed memory, or >= 1 for block memory          |
|---------------------------------------------------------------------------------------------------------------------|
| Specify the number of register stages in the port B read data pipeline. Read data output to port doutb takes this   |
| number of clkb cycles (clka when CLOCKING_MODE is "common_clock").                                                  |
| To target block memory, a value of 1 or larger is required: 1 causes use of memory latch only; 2 causes use of      |
| output register. To target distributed memory, a value of 0 or larger is required: 0 indicates combinatorial output.|
| Values larger than 2 synthesize additional flip-flops that are not retimed into memory primitives.                  |
+---------------------------------------------------------------------------------------------------------------------+
| WRITE_MODE_B         | String              | Must be "write_first", "read_first", or "no_change".                   |
|                                            | For distributed memory, must be "read_first".                          |
|---------------------------------------------------------------------------------------------------------------------|
| Designate the write mode of port B:                                                                                 |
|   "write_first": Write-first write mode                                                                             |
|   "read_first": Read-first write mode                                                                               |
|   "no_change": No-change write mode                                                                                 |
| Distributed memory configurations require read-first write mode.                                                    |
+---------------------------------------------------------------------------------------------------------------------+

Port usage table, organized as follows:
+---------------------------------------------------------------------------------------------------------------------+
| Port name      | Direction | Size, in bits                         | Domain | Sense       | Handling if unused      |
|---------------------------------------------------------------------------------------------------------------------|
| Description                                                                                                         |
+---------------------------------------------------------------------------------------------------------------------+
+---------------------------------------------------------------------------------------------------------------------+
| sleep          | Input     | 1                                     |        | Active-high | Tie to 1'b0             |
|---------------------------------------------------------------------------------------------------------------------|
| Do not change from the provided value.                                                                              |
+---------------------------------------------------------------------------------------------------------------------+
| clka           | Input     | 1                                     |        | Rising edge | Required                |
|---------------------------------------------------------------------------------------------------------------------|
| Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".                         |
+---------------------------------------------------------------------------------------------------------------------+
| rsta           | Input     | 1                                     | clka   | Active-high | Tie to 1'b0             |
|---------------------------------------------------------------------------------------------------------------------|
| Reset signal for the final port A output register stage.                                                            |
| Synchronously resets output port douta to the value specified by parameter READ_RESET_VALUE_A.                      |
+---------------------------------------------------------------------------------------------------------------------+
| ena            | Input     | 1                                     | clka   | Active-high | Tie to 1'b1             |
|---------------------------------------------------------------------------------------------------------------------|
| Memory enable signal for port A.                                                                                    |
| Must be high on clock cycles when read or write operations are initiated. Pipelined internally.                     |
+---------------------------------------------------------------------------------------------------------------------+
| regcea         | Input     | 1                                     | clka   | Active-high | Tie to 1'b1             |
|---------------------------------------------------------------------------------------------------------------------|
| Do not change from the provided value.                                                                              |
+---------------------------------------------------------------------------------------------------------------------+
| wea            | Input     | WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A | clka   | Active-high | Required                |
|---------------------------------------------------------------------------------------------------------------------|
| Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are used.                     |
| In byte-wide write configurations, each bit controls the writing one byte of dina to address addra.                 |
| For example, to synchronously write only bits [15:8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.   |
+---------------------------------------------------------------------------------------------------------------------+
| addra          | Input     | ADDR_WIDTH_A                          | clka   |             | Required                |
|---------------------------------------------------------------------------------------------------------------------|
| Address for port A write and read operations.                                                                       |
+---------------------------------------------------------------------------------------------------------------------+
| dina           | Input     | WRITE_DATA_WIDTH_A                    | clka   |             | Required                |
|---------------------------------------------------------------------------------------------------------------------|
| Data input for port A write operations.                                                                             |
+---------------------------------------------------------------------------------------------------------------------+
| injectsbiterra | Input     | 1                                     | clka   | Active-high | Tie to 1'b0             |
|---------------------------------------------------------------------------------------------------------------------|
| Do not change from the provided value.                                                                              |
+---------------------------------------------------------------------------------------------------------------------+
| injectdbiterra | Input     | 1                                     | clka   | Active-high | Tie to 1'b0             |
|---------------------------------------------------------------------------------------------------------------------|
| Do not change from the provided value.                                                                              |
+---------------------------------------------------------------------------------------------------------------------+
| douta          | Output   | READ_DATA_WIDTH_A                      | clka   |             | Required                |
|---------------------------------------------------------------------------------------------------------------------|
| Data output for port A read operations.                                                                             |
+---------------------------------------------------------------------------------------------------------------------+
| sbiterra       | Output   | 1                                      | clka   | Active-high | Leave open              |
|---------------------------------------------------------------------------------------------------------------------|
| Leave open.                                                                                                         |
+---------------------------------------------------------------------------------------------------------------------+
| dbiterra       | Output   | 1                                      | clka   | Active-high | Leave open              |
|---------------------------------------------------------------------------------------------------------------------|
| Leave open.                                                                                                         |
+---------------------------------------------------------------------------------------------------------------------+
| clkb           | Input     | 1                                     |        | Rising edge | Tie to 1'b0             |
|---------------------------------------------------------------------------------------------------------------------|
| Clock signal for port B when parameter CLOCKING_MODE is "independent_clock".                                        |
| Unused when parameter CLOCKING_MODE is "common_clock".                                                              |
+---------------------------------------------------------------------------------------------------------------------+
| rstb           | Input     | 1                                     | *      | Active-high | Tie to 1'b0             |
|---------------------------------------------------------------------------------------------------------------------|
| Reset signal for the final port B output register stage.                                                            |
| Synchronously resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.                      |
+---------------------------------------------------------------------------------------------------------------------+
| enb            | Input     | 1                                     | *      | Active-high | Tie to 1'b1             |
|---------------------------------------------------------------------------------------------------------------------|
| Memory enable signal for port B.                                                                                    |
| Must be high on clock cycles when read or write operations are initiated. Pipelined internally.                     |
+---------------------------------------------------------------------------------------------------------------------+
| regceb         | Input     | 1                                     | *      | Active-high | Tie to 1'b1             |
|---------------------------------------------------------------------------------------------------------------------|
| Do not change from the provided value.                                                                              |
+---------------------------------------------------------------------------------------------------------------------+
| web            | Input     | WRITE_DATA_WIDTH_B/BYTE_WRITE_WIDTH_B | *      | Active-high | Required                |
|---------------------------------------------------------------------------------------------------------------------|
| Write enable vector for port B input data port dinb. 1 bit wide when word-wide writes are used.                     |
| In byte-wide write configurations, each bit controls the writing one byte of dinb to address addrb.                 |
| For example, to synchronously write only bits [15:8] of dinb when WRITE_DATA_WIDTH_B is 32, web would be 4'b0010.   |
+---------------------------------------------------------------------------------------------------------------------+
| addrb          | Input     | ADDR_WIDTH_B                          | *      |             | Required                |
|---------------------------------------------------------------------------------------------------------------------|
| Address for port B write and read operations.                                                                       |
+---------------------------------------------------------------------------------------------------------------------+
| dinb           | Input     | WRITE_DATA_WIDTH_B                    | *      |             | Required                |
|---------------------------------------------------------------------------------------------------------------------|
| Data input for port B write operations.                                                                             |
+---------------------------------------------------------------------------------------------------------------------+
| injectsbiterrb | Input     | 1                                     | *      | Active-high | Tie to 1'b0             |
|---------------------------------------------------------------------------------------------------------------------|
| Do not change from the provided value.                                                                              |
+---------------------------------------------------------------------------------------------------------------------+
| injectdbiterrb | Input     | 1                                     | *      | Active-high | Tie to 1'b0             |
|---------------------------------------------------------------------------------------------------------------------|
| Do not change from the provided value.                                                                              |
+---------------------------------------------------------------------------------------------------------------------+
| doutb          | Output   | READ_DATA_WIDTH_B                      | *      |             | Required                |
|---------------------------------------------------------------------------------------------------------------------|
| Data output for port B read operations.                                                                             |
+---------------------------------------------------------------------------------------------------------------------+
| sbiterrb       | Output   | 1                                      | *      | Active-high | Leave open              |
|---------------------------------------------------------------------------------------------------------------------|
| Leave open.                                                                                                         |
+---------------------------------------------------------------------------------------------------------------------+
| dbiterrb       | Output   | 1                                      | *      | Active-high | Leave open              |
|---------------------------------------------------------------------------------------------------------------------|
| Leave open.                                                                                                         |
+---------------------------------------------------------------------------------------------------------------------+
| * clka when parameter CLOCKING_MODE is "common_clock". clkb when parameter CLOCKING_MODE is "independent_clock".    |
+---------------------------------------------------------------------------------------------------------------------+
*/

//  xpm_memory_tdpram   : In order to incorporate this function into the design, the following instance declaration
//       Verilog        : needs to be placed in the body of the design code.  The default values for the parameters
//       instance       : may be changed to meet design requirements.  The instance name (xpm_memory_tdpram)
//     declaration      : and/or the port declarations within the parenthesis may be changed to properly reference and
//         code         : connect this function to the design.  All inputs and outputs must be connected.

//  <--Cut the following instance declaration and paste it into the design-->

// xpm_memory_tdpram: True Dual Port RAM
// Xilinx Parameterized Macro, Version 2016.2
xpm_memory_tdpram # (

  // Common module parameters
  .MEMORY_SIZE        (32768),            //positive integer
  .MEMORY_PRIMITIVE   ("auto"),          //string; "auto", "distributed", "block" or "ultra";
  .CLOCKING_MODE      ("common_clock"),  //string; "common_clock", "independent_clock" 
  .MEMORY_INIT_FILE   ("none"),          //string; "none" or "<filename>.mem" 
  .MEMORY_INIT_PARAM  (""    ),          //string;
  .USE_MEM_INIT       (1),               //integer; 0,1
  .WAKEUP_TIME        ("disable_sleep"), //string; "disable_sleep" or "use_sleep_pin" 
  .MESSAGE_CONTROL    (0),               //integer; 0,1

  // Port A module parameters
  .WRITE_DATA_WIDTH_A (16),              //positive integer
  .READ_DATA_WIDTH_A  (16),              //positive integer
  .BYTE_WRITE_WIDTH_A (16),              //integer; 8, 9, or WRITE_DATA_WIDTH_A value
  .ADDR_WIDTH_A       (11),               //positive integer
  .READ_RESET_VALUE_A ("0"),             //string
  .READ_LATENCY_A     (2),               //non-negative integer
  .WRITE_MODE_A       ("no_change"),     //string; "write_first", "read_first", "no_change" 

  // Port B module parameters
  .WRITE_DATA_WIDTH_B (16),              //positive integer
  .READ_DATA_WIDTH_B  (16),              //positive integer
  .BYTE_WRITE_WIDTH_B (16),              //integer; 8, 9, or WRITE_DATA_WIDTH_B value
  .ADDR_WIDTH_B       (11),               //positive integer
  .READ_RESET_VALUE_B ("0"),             //vector of READ_DATA_WIDTH_B bits
  .READ_LATENCY_B     (2),               //non-negative integer
  .WRITE_MODE_B       ("no_change")      //string; "write_first", "read_first", "no_change" 

) dpram_upper (

  // Common module ports
  .sleep          (1'b0),

  // Port A module ports
  .clka           (clk100),
  .rsta           (rst_n),
  .ena            (1'b1),             //  This is the upper part memory, which is selected by the highest address bit being '0'
  .regcea         (1'b1),
  .wea            (1'b0),
  .addra          ({backbuffer,rd_addr_front_buffer[9:0]}),
  .dina           (16'bz),                  //  No real inputs because we never write on this port
  .injectsbiterra (1'b0),  //do not change
  .injectdbiterra (1'b0),  //do not change
  .douta          (rd_data_front_buffer_upper),
  .sbiterra       (),      //do not change
  .dbiterra       (),      //do not change

  // Port B module ports
  .clkb           (clk100),
  .rstb           (rst_n),
  .enb            (!addr_b[10]),
  .regceb         (!addr_b[10]),
  .web            (wr_ena & !addr_b[10]),
  .addrb          ({~backbuffer,addr_b[9:0]}),
  .dinb           (data_b),
  .injectsbiterrb (1'b0),  //do not change
  .injectdbiterrb (1'b0),  //do not change
  .doutb          (data_hi_b),
  .sbiterrb       (),      //do not change
  .dbiterrb       ()       //do not change

);

// End of xpm_memory_tdpram instance declaration


// xpm_memory_tdpram: True Dual Port RAM
// Xilinx Parameterized Macro, Version 2016.2
xpm_memory_tdpram # (

  // Common module parameters
  .MEMORY_SIZE        (32768),            //positive integer
  .MEMORY_PRIMITIVE   ("auto"),          //string; "auto", "distributed", "block" or "ultra";
  .CLOCKING_MODE      ("common_clock"),  //string; "common_clock", "independent_clock" 
  .MEMORY_INIT_FILE   ("none"),          //string; "none" or "<filename>.mem" 
  .MEMORY_INIT_PARAM  (""    ),          //string;
  .USE_MEM_INIT       (1),               //integer; 0,1
  .WAKEUP_TIME        ("disable_sleep"), //string; "disable_sleep" or "use_sleep_pin" 
  .MESSAGE_CONTROL    (0),               //integer; 0,1

  // Port A module parameters
  .WRITE_DATA_WIDTH_A (16),              //positive integer
  .READ_DATA_WIDTH_A  (16),              //positive integer
  .BYTE_WRITE_WIDTH_A (16),              //integer; 8, 9, or WRITE_DATA_WIDTH_A value
  .ADDR_WIDTH_A       (11),               //positive integer
  .READ_RESET_VALUE_A ("0"),             //string
  .READ_LATENCY_A     (2),               //non-negative integer
  .WRITE_MODE_A       ("no_change"),     //string; "write_first", "read_first", "no_change" 

  // Port B module parameters
  .WRITE_DATA_WIDTH_B (16),              //positive integer
  .READ_DATA_WIDTH_B  (16),              //positive integer
  .BYTE_WRITE_WIDTH_B (16),              //integer; 8, 9, or WRITE_DATA_WIDTH_B value
  .ADDR_WIDTH_B       (11),               //positive integer
  .READ_RESET_VALUE_B ("0"),             //vector of READ_DATA_WIDTH_B bits
  .READ_LATENCY_B     (2),               //non-negative integer
  .WRITE_MODE_B       ("no_change")      //string; "write_first", "read_first", "no_change" 

) dpram_lower (

  // Common module ports
  .sleep          (1'b0),

  // Port A module ports
  .clka           (clk100),
  .rsta           (rst_n),
  .ena            (1'b1),             //  This is the lower part memory, which is selected by the highest address bit being '1'
  .regcea         (1'b1),
  .wea            (1'b0),
  .addra          ({backbuffer,rd_addr_front_buffer[9:0]}),
  .dina           (16'bz),                  //  No real inputs because we never write on this port
  .injectsbiterra (1'b0),  //do not change
  .injectdbiterra (1'b0),  //do not change
  .douta          (rd_data_front_buffer_lower),
  .sbiterra       (),      //do not change
  .dbiterra       (),      //do not change

  // Port B module ports
  .clkb           (clk100),
  .rstb           (rst_n),
  .enb            (addr_b[10]),
  .regceb         (addr_b[10]),
  .web            (wr_ena && addr_b[10]),
  .addrb          ({~backbuffer,addr_b[9:0]}),
  .dinb           (data_b),
  .injectsbiterrb (1'b0),  //do not change
  .injectdbiterrb (1'b0),  //do not change
  .doutb          (data_lo_b),
  .sbiterrb       (),      //do not change
  .dbiterrb       ()       //do not change

);

    assign data_b = { addr_b ? data_lo_b : data_hi_b };
    
// End of xpm_memory_tdpram instance declaration


endmodule
