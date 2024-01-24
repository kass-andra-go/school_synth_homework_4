
module formula_1_pipe_with_shift_reg
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output logic        res_vld,
    output logic [31:0] res
);

    parameter N = 8;
    logic        isqrt_x_vld_2, isqrt_x_vld_3;
    logic [31:0] isqrt_x_2, isqrt_x_3;

    logic        isqrt_y_vld_1, isqrt_y_vld_2, isqrt_y_vld_3;
    logic [15:0] isqrt_y_1, isqrt_y_2, isqrt_y_3;
    logic [31:0] y_2, y_3;
    logic reg_y_vld_2, reg_y_vld_3;
    logic [31:0] y_bc, y_abc;


    isqrt # (.n_pipe_stages (N)) i_isqrt_1
    (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( arg_vld       ),
        .x     ( c             ),
        .y_vld ( isqrt_y_vld_1 ),
        .y     ( isqrt_y_1     )
    );


    shift_register_with_valid 
    # (
        .width(32), .depth(N)
    ) shift_reg_1 
    (
        .clk(clk),
        .rst(rst),
        .in_vld(arg_vld),
        .in_data(b),
        .out_vld(reg_y_vld_2),
        .out_data(y_2)
    );

    assign y_bc = {16'b0, isqrt_y_1} + y_2;

    always_ff @(posedge clk)
    begin
        if (isqrt_y_vld_1)
            isqrt_x_2 <= y_bc;
    end

    always_ff @(posedge clk)
    begin
        if (rst)
            isqrt_x_vld_2 = 1'b0;
        else
            isqrt_x_vld_2 <= isqrt_y_vld_1;
    end

    isqrt # (.n_pipe_stages (N)) i_isqrt_2
    (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( isqrt_x_vld_2 ),
        .x     ( isqrt_x_2     ),
        .y_vld ( isqrt_y_vld_2 ),
        .y     ( isqrt_y_2     )
    );
    
   shift_register_with_valid 
    # (
        .width(32), .depth(2*N+1)
    ) shift_reg_2
    (
        .clk(clk),
        .rst(rst),
        .in_vld(arg_vld),
        .in_data(a),
        .out_vld(reg_y_vld_3),
        .out_data(y_3)
    );

    assign y_abc = {16'b0,isqrt_y_2} + y_3;

    always_ff @(posedge clk)
    begin
        if (isqrt_y_vld_2)
            isqrt_x_3 <= y_abc;
    end

    always_ff @(posedge clk)
    begin
        if (rst)
            isqrt_x_vld_3 = 1'b0;
        else
            isqrt_x_vld_3 <= isqrt_y_vld_2;
    end


    isqrt # (.n_pipe_stages (N)) i_isqrt_3
    (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( isqrt_x_vld_3 ),
        .x     ( isqrt_x_3     ),
        .y_vld ( isqrt_y_vld_3 ),
        .y     ( isqrt_y_3     )
    );

    assign res = {16'b0, isqrt_y_3};
    assign res_vld = isqrt_y_vld_3;

endmodule
