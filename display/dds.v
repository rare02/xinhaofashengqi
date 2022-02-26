`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : dds
// Project Name  : top_dds
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : DDS信号发生器
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  dds
(
    input   wire            sys_clk     ,   //系统时钟,50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire    [3:0]   wave_select ,   //输出波形选择
	 input   wire       		 c_mode      ,   //输入4位按键
	 input   wire    [1:0]   keyjj       ,   //输出波形选择

    output  wire    [7:0]   data_out        //波形输出
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   CNT_MAX =   20'd999_999;    //计数器计数最大值
parameter   sin_wave    =    2'b00,   //正弦波
            squ_wave    =    2'b01,   //方波
            tri_wave    =    2'b10,   //三角波
            saw_wave    =    2'b11;   //锯齿波

				//wire  define
wire            key3    ;   //按键3
wire            key2    ;   //按键2
wire            key1    ;   //按键1

//reg   define

				
reg     [31:0]  FREQ_CTRL   =   32'd21474836   ;   //相位累加器单次累加值
reg     [11:0]  PHASE_CTRL  =   9'd256    ;   //相位偏移量

reg   			 mode_show   =   1'b0        ;  		
reg     [31:0]  fre_add     ;   //相位累加器
reg     [8:0]  rom_addr_reg;   //相位调制后的相位码
reg     [10:0]  rom_addr    ;   //ROM读地址

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mode_show   <=  1'b0;
    else  if(key3 == 1'b1)
        mode_show   <=  ~mode_show ;
    else
        mode_show   <=  mode_show;
		  
always@(posedge sys_clk or negedge sys_rst_n)
	 if(sys_rst_n == 1'b0)
		begin
        FREQ_CTRL   <=  32'd21474836   ;
		  PHASE_CTRL   <= 9'd256    ;
		 end
	 else
		case(mode_show )
		1'b0:
	      begin
	 	    if(key2 ==1'b1)
             FREQ_CTRL   <=  FREQ_CTRL+32'd1932735 ;
	 	     else if (key1 ==1'b1)
	 	      FREQ_CTRL   <=  FREQ_CTRL-32'd1932735 ;
	 	     else 
	 	      FREQ_CTRL   <=  FREQ_CTRL;
	      end
		1'b1:
        begin
	 	    if(key2 ==1'b1)
				 PHASE_CTRL   <=  PHASE_CTRL+9'd20 ;
	 	     else if (key1 ==1'b1)
	 	         PHASE_CTRL   <=  PHASE_CTRL-9'd20 ;
	 	     else 
	 	      PHASE_CTRL   <=  PHASE_CTRL;
	      end
		endcase


//fre_add:相位累加器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fre_add <=  32'd0;
    else
        fre_add <=  fre_add + FREQ_CTRL;
		
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rom_addr_reg <=  9'd0;
    else
	        rom_addr_reg    <=  fre_add[31:23] + PHASE_CTRL;

		  
		  
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rom_addr <= 11'd0;
    else
    case(wave_select)
        sin_wave:
            begin
                rom_addr        <=  rom_addr_reg;
            end     //正弦波
        squ_wave:
            begin
                rom_addr        <=  rom_addr_reg + 11'd512;
            end     //方波
        tri_wave:
            begin
                rom_addr        <=  rom_addr_reg + 11'd1024;
            end     //三角波
        saw_wave:
        begin
                rom_addr        <=  rom_addr_reg + 11'd1536; 
            end     //锯齿波
        default:
            begin
                rom_addr        <=  rom_addr_reg;
            end     //正弦波
    endcase

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------------------- rom_wave_inst ------------------------
rom_wave    rom_wave_inst
(
    .address    (rom_addr   ),  //ROM读地址
    .clock      (sys_clk    ),  //读时钟

    .q          (data_out   )   //读出波形数据
);



//------------- key_fifter_inst3 --------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_filter_inst3
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (c_mode   )   ,   //按键输入信号

    .key_flag     (key3     )       //按键消抖后标志信号
);

//------------- key_fifter_inst2 --------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_filter_inst2
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (keyjj[1]   )   ,   //按键输入信号

    .key_flag     (key2     )       //按键消抖后标志信号
);

//------------- key_fifter_inst1 --------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_filter_inst1
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (keyjj[0]   )   ,   //按键输入信号

 .key_flag     (key1     )       //按键消抖后标志信号
);



endmodule
