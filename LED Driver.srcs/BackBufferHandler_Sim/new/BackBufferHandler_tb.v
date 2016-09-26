
module BackBufferHandler_tb ();

    reg rst_n;
    reg v_sync;
    reg switch_req;
    
    wire backbuffer_out;
    wire clr_switch_req;
    
    BackBufferHandler   DUT (
        .rst_n(rst_n),
        .v_sync(v_sync),
        .backbuffer_out(backbuffer_out),
        .switch_req(switch_req),
        .clr_switch_req(clr_switch_req)
    );
    
    
    initial begin
        rst_n = 1;
        v_sync = 0;
        switch_req = 0;
        
        #10 rst_n = 0;
        #10 rst_n = 1;
        
        #10 switch_req = 1;         //  If backbuffer_out switches here, the test failed    (test v_sync edge with switch_req)
        #10 v_sync = 1;             //  if backbuffer_out switches here, the test is successful
        #10 v_sync = 0;
        #10 switch_req = 0;
        #10 v_sync = 1;             //  if backbuffer_out switches here, the test failed (test v_sync edge without switch_req
        #10 switch_req = 1;
        #10 v_sync = 0;
        
        #10 v_sync = 1;             //  Test backbuffer flip to 0 again
        
        #20
        $finish;
    end
    
endmodule