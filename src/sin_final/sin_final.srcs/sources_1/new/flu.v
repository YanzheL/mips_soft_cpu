`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2018 03:54:31 PM
// Design Name: 
// Module Name: FLU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "global_define.v"

module FLU #(parameter WIDTH = 32) (
        input                       CLK, Reset,
        input         [WIDTH-1:0]   A,B,
        input         [10:0]        ControlCode,
        output  reg   [WIDTH-1:0]   Result,
        output  reg                 PREPARED
    );
    reg                            adden,suben,mulen,diven,cvt_sw_en, cvt_ws_en,cmpen;
    wire              [WIDTH-1:0]  alu_res,mult_res,div_res,cvt_sw_res,cvt_ws_res;
    wire              [7:0]        cmp_res;
    wire                           adder_valid, mult_valid, div_valid,cvt_sw_valid,cvt_ws_valid,cmp_valid;
    
    always @(*) begin
        adden  <= 0; suben  <= 0; mulen  <= 0; diven  <= 0; cmpen  <= 0; cvt_sw_en <= 0;cvt_ws_en <= 0;
        case (ControlCode[10:6])
            `FLOAT_FMT:
                case (ControlCode[5:0])
                    `FLU_ADD_S_FUNC:  adden <= 1;
                    `FLU_SUB_S_FUNC:  suben <= 1;
                    `FLU_MUL_S_FUNC:  mulen <= 1;
                    `FLU_DIV_S_FUNC:  diven <= 1;
                    `FLU_CMP_LE_FUNC: cmpen <= 1;
                    `FLU_CMP_LT_FUNC: cmpen <= 1;
                    `FLU_CMP_EQ_FUNC: cmpen <= 1;
                    `FLU_CVT_WS_FUNC: cvt_ws_en <= 1;
//                    default: begin adden  <= 0; suben  <= 0; mulen  <= 0; diven  <= 0; cmpen  <= 0; cvt_sw_en <= 0;cvt_ws_en <= 0; end
                endcase
            `FIXED_FMT:
                case (ControlCode[5:0])
                    `FLU_CVT_SW_FUNC: cvt_sw_en <= 1;
//                    default: begin adden  <= 0; suben  <= 0; mulen  <= 0; diven  <= 0; cmpen  <= 0; cvt_sw_en <= 0; cvt_ws_en <= 0; end
                endcase
//            default: begin adden  <= 0; suben  <= 0; mulen  <= 0; diven  <= 0; cmpen  <= 0; cvt_sw_en <= 0; cvt_ws_en <= 0; end
        endcase
    end

    falu falu_core(
       .aclk(CLK),
       .aresetn(~Reset),
       .s_axis_a_tdata(A),
       .s_axis_a_tvalid(adden|suben),
       .s_axis_b_tdata(B),
       .s_axis_b_tvalid(adden|suben),
       .s_axis_operation_tdata({2'b00,ControlCode[5:0]}),
       .s_axis_operation_tvalid(adden|suben),
       .m_axis_result_tdata(alu_res),
       .m_axis_result_tvalid(adder_valid)
    );
    
    fmult fmult_core(
       .aclk(CLK),
       .aresetn(~Reset),
       .s_axis_a_tdata(A),
       .s_axis_a_tvalid(mulen),
       .s_axis_b_tdata(B),
       .s_axis_b_tvalid(mulen),
       .m_axis_result_tdata(mult_res),
       .m_axis_result_tvalid(mult_valid)
    );
    
    fdiv fdiv_core(
       .aclk(CLK),
       .aresetn(~Reset),
       .s_axis_a_tdata(A),
       .s_axis_a_tvalid(diven),
       .s_axis_b_tdata(B),
       .s_axis_b_tvalid(diven),
       .m_axis_result_tdata(div_res),
       .m_axis_result_tvalid(div_valid)
    );
    
    fixed_to_float fix_to_float_core(
        .aclk(CLK),
        .aresetn(~Reset),
        .s_axis_a_tdata(A),
        .s_axis_a_tvalid(cvt_sw_en),
        .m_axis_result_tdata(cvt_sw_res),
        .m_axis_result_tvalid(cvt_sw_valid)
    );
    
    float_to_fixed float_to_fixed_core(
        .aclk(CLK),
        .aresetn(~Reset),
        .s_axis_a_tdata(A),
        .s_axis_a_tvalid(cvt_ws_en),
        .m_axis_result_tdata(cvt_ws_res),
        .m_axis_result_tvalid(cvt_ws_valid)
    );
    
    fcompare fcompare_core(
        .aclk(CLK),
        .aresetn(~Reset),
        .s_axis_a_tdata(A),
        .s_axis_a_tvalid(cmpen),
        .s_axis_b_tdata(B),
        .s_axis_b_tvalid(cmpen),
        .m_axis_result_tdata(cmp_res),
        .m_axis_result_tvalid(cmp_valid)
    );

    always @(*) begin
        if(Reset) begin
            PREPARED <= 0;
            Result   <= 32'b0;
        end
        else begin
            case (ControlCode[10:6])
                `FLOAT_FMT:
                    case (ControlCode[5:0])
                        `FLU_ADD_S_FUNC: begin
                             PREPARED <= adder_valid==1;
                             if(PREPARED) Result <= alu_res;
                             else Result<=Result;
                        end
                        `FLU_SUB_S_FUNC: begin
                             PREPARED <= adder_valid==1;
                             if(PREPARED) Result <= alu_res;
                             else Result<=Result;
                        end
                        `FLU_MUL_S_FUNC: begin
                             PREPARED <= mult_valid==1;
                             if(PREPARED) Result <= mult_res;
                             else Result<=Result;
                         end
                        `FLU_DIV_S_FUNC: begin
                             PREPARED <= div_valid==1;
                             if(PREPARED) Result <= div_res;
                             else Result<=Result;
                         end
                        `FLU_CMP_LE_FUNC: begin
                             PREPARED <= cmp_valid==1;
                             if(PREPARED) Result <= {24'b0,cmp_res};
                             else Result<=Result;
                         end
                        `FLU_CMP_LT_FUNC: begin
                             PREPARED <= cmp_valid==1;
                             if(PREPARED) Result <= {24'b0,cmp_res};
                             else Result<=Result;
                         end
                         `FLU_CMP_EQ_FUNC: begin
                              PREPARED <= cmp_valid==1;
                              if(PREPARED) Result <= {24'b0,cmp_res};
                              else Result<=Result;
                          end
                         `FLU_CVT_WS_FUNC: begin
                             PREPARED <= cvt_ws_valid==1;
                             if(PREPARED) Result <= cvt_ws_res;
                             else Result<=Result;
                          end
                          default: Result<=Result;
                    endcase
                `FIXED_FMT:
                    case (ControlCode[5:0])
                        `FLU_CVT_SW_FUNC: begin
                            PREPARED <= cvt_sw_valid==1;
                            if(PREPARED) Result <= cvt_sw_res;
                            else Result<=Result;
                         end
                         default: Result<=Result;
                    endcase
                default: Result<=Result;
            endcase
        end
    end
endmodule
