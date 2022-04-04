`timescale 1ns / 1ps

`include "HardFloat_consts.vi"
`include "HardFloat_specialize.vi"

module sqrt_tb;

    // Formats                     Exp  Sig
    // 16-bit  half-precision      5    11
    // 32-bit  single-precision    8    24
    // 64-bit  double-precision    11   53
    // 128-bit quadruple-precision 15   113
    
    localparam ExpWidth     = 8;
    localparam SigWidth     = 24;
    localparam FormatWidth  = ExpWidth + SigWidth;

    reg clk_i;
    reg rst_ni;

    reg                        in_valid_i;
    wire                       in_ready_o;
    reg  [(FormatWidth - 1):0] a;
    wire [(FormatWidth - 1):0] c;
    wire [FormatWidth:0]       rec_a;
    wire [FormatWidth:0]       rec_c;
    wire                       out_valid_o;
    wire [4:0]                 excp_flags_o;

    reg [31:0] memory [0:7];
    
    reg [2:0] i;

    initial begin
        // calculated via https://www.h-schmidt.net/FloatConverter/IEEE754.html
        //               Binary                                  Decimal              Hexadecimal    Results       Cycles
        memory[0] = 32'b 0_10000010_10000000000000000000000;  // 12                   0x41400000     0x405db3d7    23          
        memory[1] = 32'b 0_10000000_10000000000000000000000;  // 3                    0x40400000     0x3fddb3d7    23
        memory[2] = 32'b 1_10000100_00101000000000000000000;  // -37                  0xc2140000     NaN           0
        memory[3] = 32'b 0_10000011_00011000000000000000000;  // 17.5                 0x418c0000     0x4085dd98    26
        memory[4] = 32'b 0_10001001_01100001100000000000000;  // 1414                 0x44b0c000     0x421669ab    24
        memory[5] = 32'b 0_10001100_10011010010110000000000;  // 13131                0x464d2c00     0x42e52e60    23
        memory[6] = 32'b 0_00000000_10011010010110000000000;  // 7.08711743007e-39    0x004d2c00     0x1fc6c6b9    23
        memory[7] = 32'b 0_00000000_00010011110110000000000;  // 9.11180313443e-40    0x0009ec00     0x1f0e8c59    24
    end

    initial begin
        clk_i      = 1;
        rst_ni     = 0;
        in_valid_i = 0;
        a          = 0;
        i          = 0;
    end

    always #5 clk_i = ~clk_i;

    initial begin
        repeat (2) @(posedge clk_i);
        rst_ni = 1;
        repeat (500) @(posedge clk_i);
        $finish;
    end

    initial begin
        $dumpfile("sqrt_tb.vcd");
        $dumpvars(0, sqrt_tb);
    end

    divSqrtRecFN_small #(
        .expWidth(ExpWidth),
        .sigWidth(SigWidth)
    ) divSqrtRecFN_uut (
        .nReset         (rst_ni),
        .clock          (clk_i),
        .inReady        (in_ready_o),
        .inValid        (in_valid_i),
        .sqrtOp         (1'b1),
        .a              (rec_a),
        .roundingMode   (3'b000),
        .outValid       (out_valid_o),
        .out            (rec_c),
        .exceptionFlags (excp_flags_o)
    );

    fNToRecFN #(
        .expWidth(ExpWidth),
        .sigWidth(SigWidth)
    ) a_fNToRecFN_uut (
        .in(a),
        .out(rec_a)
    );

    recFNToFN #(
        .expWidth(ExpWidth),
        .sigWidth(SigWidth)
    ) c_recFNToFN_uut (
        .in(rec_c),
        .out(c)
    );

    always @(posedge clk_i) begin
        if (!rst_ni) begin
            in_valid_i <= 0;
            a          <= 0;
            i          <= 0;
        end else begin            
            if ( !in_valid_i && in_ready_o ) begin
                in_valid_i <= 1'b1;
                a          <= memory[i];
                i          <= i + 1;
            end else begin
                in_valid_i <= 1'b0;
            end
        end
    end

endmodule
