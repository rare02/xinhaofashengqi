`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : key_control
// Project Name  : top_dds
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 按键控制模块,控制波形选择
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  key_control
(
    input   wire            sys_clk     ,   //系统时钟,50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire       		 key_wave         ,   //输入4位按键

    output  reg     [3:0]   wave_select     //输出波形选择
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   sin_wave    =   2'b00,    //正弦波
            squ_wave    =   2'b01,    //方波
            tri_wave    =   2'b10,    //三角波
            saw_wave    =   2'b11;    //锯齿波

parameter   CNT_MAX =   20'd999_999;    //计数器计数最大值

//wire  define
wire            key0    ;   //按键0

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//wave:按键状态对应波形
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wave_select   <=  2'b00;
    else    if(key0 == 1'b1)
			if	(wave_select == 2'b11)
			wave_select   <=2'b00;
			else
        wave_select   <=  wave_select + 1;
    else
        wave_select   <=  wave_select;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- key_fifter_inst0 --------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_filter_inst0
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key_wave  )   ,   //按键输入信号

    .key_flag     (key0     )       //按键消抖后标志信号
);

endmodule
