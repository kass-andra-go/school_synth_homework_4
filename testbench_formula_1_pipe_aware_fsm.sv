//Поменять кодировку change code
//encoding system utf-8

module testbench_formula_1_pipe_aware_fsm();

    logic clk, aresetn;
    //logic x_vld, y_vld;
    logic arg_vld, res_vld;
    logic [31:0] a_data, b_data, c_data;
    //logic [31:0] x_data; 
    //logic [15:0] y_data;
    logic [31:0] y_res;
    int errors;
    //int cnt;

/*formula_1_pipe dut(
    .clk (clk),
    .rst (aresetn),
    .arg_vld(x_vld),
    .a (a_data),
    .b (b_data),
    .c (c_data),
    .res_vld (y_vld),
    .res(y_data)
);*/

/*isqrt dut(
    .clk (clk),
    .rst (~aresetn),
    .x_vld(x_vld),
    .x (x_data),
    .y_vld (y_vld),
    .y(y_data)
);

formula_1_pipe_aware_fsm fsm_dut(

.clk (clk),
.rst (~aresetn),

.arg_vld(arg_vld),
.a (a_data),
.b (b_data),
.c (c_data),

.res_vld(res_vld),
.res(y_res),

// isqrt interface

.isqrt_x_vld(x_vld),
.isqrt_x(x_data),

.isqrt_y_vld(y_vld),
.isqrt_y(y_data)
);
*/
formula_1_pipe_aware_fsm_top_copy dut (
    .clk(clk),
   .rst (~aresetn),

     .arg_vld (arg_vld),
     .a (a_data),
     .b (b_data),
     .c (c_data),

      .res_vld (res_vld),
     .res (y_res)
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
    // Генерация сигнала сброса
    initial begin
        aresetn <= 0;
        #(CLK_PERIOD);
        aresetn <= 1;
    end

    // Пакет и mailbox'ы
    typedef struct {
        logic [31:0] data_a;
        logic [31:0] data_b;
        logic [31:0] data_c;
    } inpacket;

    typedef struct {
        logic [31:0] data;
    } outpacket;

    mailbox#(inpacket) in_mbx  = new();
    mailbox#(outpacket) out_mbx = new();

//генерация случайного числа по условию
task task_generate_x(output logic [31:0] x_data);
    do begin
            x_data = $urandom_range(4, 100);
        end
        while(~((x_data == 4) | (x_data == 25) | (x_data == 36) | (x_data == 49) | (x_data == 64) | (x_data == 81) | (x_data == 100)));
endtask : task_generate_x

//генерация входных воздействий
initial begin
    wait (aresetn);
    a_data = 0;
    b_data = 0;
    c_data = 0;
    arg_vld = 0;
    wait (aresetn);
    repeat (20)
    begin
        //void'(std::randomize (x_data) with {x_data dist {4 :/20, 25 :/ 20, 49 :/20, 81 :/20, 100 :/20 };}); 
        //x_data = 32'd100;
        //repeat (18) @(posedge clk);
        repeat (9) @(posedge clk);

        task_generate_x(a_data);
        task_generate_x(b_data);
        task_generate_x(c_data);
        
        arg_vld = 1;
        $display ("Input signals generation");
        #CLK_PERIOD;
        arg_vld <= 0;
        #CLK_PERIOD;
    end
    $display ("Stop! Errors = %d", errors);
    $stop;
end

//мониторинг входов
initial begin
    inpacket p;
    wait (aresetn);
    forever begin
        @( clk);
        //$display ("Input monitoring forever");
        if (arg_vld == 1'b1 ) begin
            p.data_a = a_data;
            p.data_b = b_data;
            p.data_c = c_data;
            $display ("Input monitoring");
            in_mbx.put(p);
            //$display ("Input monitoring put");
        end
    end
end

//мониторинг выходов
initial begin
    outpacket p;
    wait (aresetn);
    forever begin
        @(posedge clk);
        if (res_vld == 1'b1) begin
            p.data = y_res;
            $display ("Output monitoring");
            out_mbx.put(p);
            //$display ("Output monitoring put");
        end
    end
end

// Проверка
    initial begin
        inpacket in_p;
        outpacket out_p;
        logic [31:0] pow;
        forever begin
            in_mbx.get(in_p);
            out_mbx.get(out_p);
            //$display ("Check");
            $display ("%0t Check: A = %d B = %d C = %d Y = %d", $time(), in_p.data_a, in_p.data_b, in_p.data_c, out_p.data);
            //pow = out_p.data * out_p.data;
            pow = $sqrt (in_p.data_a) + $sqrt (in_p.data_b) + $sqrt (in_p.data_c);
            if( out_p.data !== pow ) begin
                $error("%0t Invalid sqrt: Real: %d, Expected pow: %d",
                    $time(), out_p.data, pow);
                    errors = errors+1;
            end
        end
    end

    // Таймаут теста
    initial begin
        repeat(100) @(posedge clk);
        $display ("Timeout! Errors = %d", errors);
        $stop();
    end
endmodule
