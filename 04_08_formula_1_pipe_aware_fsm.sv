//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);
    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

enum logic [2:0]
{
    st_start_a      = 3'b000,
    st_wait_a_res   = 3'b001,
    st_start_b      = 3'b010,
    st_wait_b_res   = 3'b011,
    st_start_c      = 3'b100,
    st_wait_c_res   = 3'b101,
    st_result       = 3'b110,
    st_idle         = 3'b111
}
state, next_state;

always_comb
begin
    next_state  = state;

    case (state)
    st_idle:
    begin
        if (arg_vld)
        begin
            next_state = st_start_a;
        end
    end
    st_start_a:
    begin
            next_state = st_wait_a_res;
    end
    st_wait_a_res:
    begin
        if (isqrt_y_vld)
            next_state = st_start_b;
        else
            next_state = st_wait_a_res;
    end
    st_start_b:
    begin
        next_state = st_wait_b_res;
    end
    st_wait_b_res:
    begin
        if (isqrt_y_vld)
            next_state = st_start_c;
        else
            next_state = st_wait_b_res;
    end
    st_start_c:
    begin
        next_state = st_wait_c_res;
    end
    st_wait_c_res:
    begin
        if (isqrt_y_vld)
            next_state = st_result;
        else
            next_state = st_wait_c_res;
    end
    st_result:
    begin
        next_state = st_idle;
    end
    endcase
end

// Datapath

always_comb
begin
    //isqrt_x_vld = 1'b0;

    case (state)
    st_start_a       : isqrt_x_vld = 1'b1;
    st_wait_a_res    : isqrt_x_vld = 1'b0; 
    st_start_b       : isqrt_x_vld = 1'b1;
    st_wait_b_res    : isqrt_x_vld = 1'b0; 
    st_start_c       : isqrt_x_vld = 1'b1;
    st_wait_c_res    : isqrt_x_vld = 1'b0;
    st_result        : isqrt_x_vld = 1'b0;

    default: isqrt_x_vld = 1'b0;
    endcase
end

always_comb
begin
    //isqrt_x = 'x;  // Don't care

    case (state)
    st_start_a       : isqrt_x = a;
    st_start_b       : isqrt_x = b;
    st_start_c       : isqrt_x = c;
    default: isqrt_x = 32'bx;

    endcase
end

//------------------------------------------------------------------------
// Assigning next state

always_ff @ (posedge clk)
if (rst)
    state <= st_idle;
else
    state <= next_state;

//------------------------------------------------------------------------
// Accumulating the result

always_ff @ (posedge clk)
if (rst)
    res_vld <= '0;
else
    res_vld <= (state == st_result);

always_ff @ (posedge clk)
if (state == st_idle)
    res <= '0;
else if (isqrt_y_vld)
    res <= res + {{15{1'b0}}, isqrt_y};

//---------------------------------------------------------------------------

endmodule
