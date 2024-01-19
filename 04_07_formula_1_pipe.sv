//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        logic res_vld,
    output logic [31:0] res
);
    // Task:
    //
    // Implement a pipelined module formula_1_pipe that computes the result
    // of the formula defined in the file formula_1_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_1_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

logic [15:0] a_res, b_res, c_res;
logic res_vld1, res_vld2, res_vld3;

isqrt dut1(
    .clk (clk),
    .rst (rst),
    .x_vld(arg_vld),
    .x (a),
    .y_vld (res_vld1),
    .y(a_res)
);

isqrt dut2(
    .clk (clk),
    .rst (rst),
    .x_vld(arg_vld),
    .x (b),
    .y_vld (res_vld2),
    .y(b_res)
);

isqrt dut3(
    .clk (clk),
    .rst (rst),
    .x_vld(arg_vld),
    .x (c),
    .y_vld (res_vld3),
    .y(c_res)
);

always_ff @( clk ) begin : result_ff
    if (rst)
        res = 0;
    else if (res_vld1) begin
        res = {16'b0, a_res} + {16'b0, b_res} + {16'b0, c_res};
    end
end

always_ff @(clk) begin : valid_ff
    if (rst)
        res_vld = 0;
    else
        res_vld = res_vld1;
end

endmodule
