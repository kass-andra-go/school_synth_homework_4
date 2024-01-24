module tb_shift_reg();

logic clk, rst;
logic [7:0] indata, outdata;
logic invld, outvld;
logic f;

shift_register_with_valid dut
(
    .clk(clk),
    .rst(rst),

    .in_vld(invld),
    .in_data(indata),

    .out_vld(outvld),
    .out_data(outdata)
);

// период тактового сигнала
    parameter CLK_PERIOD = 10;
// генерация тактового сигнала
    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD/2) clk <= ~clk;
        end
    end


initial begin
   invld = 0;
   indata = 8'b0; 
   f=0;
   rst = 1;
   #CLK_PERIOD;
   rst = 0;
end

always @ (posedge clk)
begin
    if (f)
    begin
        indata = indata + 8'b100;
        invld = 1;
        f = ~f;
    end
    else
    begin
        invld = 0;
        f = ~f;
    end

    $display ("%t: in_data = %d, out_vld = %b, out_data = %d", $time, indata, outvld, outdata);
    if (indata > 8'hf0)
        $stop;
end

/*always @(negedge clk)
begin
    invld = 0;
end
*/

endmodule
