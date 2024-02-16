module tb_shift_reg_v2();

logic clk, rst;
logic [7:0] indata, outdata;
logic invld, outvld;
//logic f;
int cnt;

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
   //f=0;
   rst = 1;
   #CLK_PERIOD;
   rst = 0;
end

always @ (posedge clk)
begin
    //indata = indata + 8'b100;
    indata = $urandom_range(0,255);
    //invld = 1;
    invld = $urandom_range(0,1);

    $display ("%t: in_data = %d, out_vld = %b, out_data = %d", $time, indata, outvld, outdata);
    if (cnt > 100)
        $stop;
    cnt = cnt + 1;
end


endmodule
