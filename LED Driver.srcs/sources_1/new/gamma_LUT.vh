function [7:0] gamma_LUT;
    input [4:0] inval;

    case (inval)
        5'd0:   gamma_LUT = 0;
        5'd1:   gamma_LUT = 0;
        5'd2:   gamma_LUT = 0;
        5'd3:   gamma_LUT = 1;
        5'd4:   gamma_LUT = 2;
        5'd5:   gamma_LUT = 3;
        5'd6:   gamma_LUT = 4;
        5'd7:   gamma_LUT = 6;
        5'd8:   gamma_LUT = 9;
        5'd9:   gamma_LUT = 12; 
        5'd10:  gamma_LUT = 15;
        5'd11:  gamma_LUT = 19;
        5'd12:  gamma_LUT = 24;
        5'd13:  gamma_LUT = 29;
        5'd14:  gamma_LUT = 35;
        5'd15:  gamma_LUT = 42;
        5'd16:  gamma_LUT = 49;
        5'd17:  gamma_LUT = 57;
        5'd18:  gamma_LUT = 66;
        5'd19:  gamma_LUT = 75;
        5'd20:  gamma_LUT = 86;
        5'd21:  gamma_LUT = 97;
        5'd22:  gamma_LUT = 109;
        5'd23:  gamma_LUT = 121;
        5'd24:  gamma_LUT = 135;
        5'd25:  gamma_LUT = 150;
        5'd26:  gamma_LUT = 165;
        5'd27:  gamma_LUT = 181;
        5'd28:  gamma_LUT = 198;
        5'd29:  gamma_LUT = 217;
        5'd30:  gamma_LUT = 236;
        5'd31:  gamma_LUT = 255;
    endcase
endfunction
