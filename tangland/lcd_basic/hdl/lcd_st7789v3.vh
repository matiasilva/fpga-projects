`ifndef LCD_ST7789V3_VH
`define LCD_ST7789V3_VH

`define  MADCTL_CMD 8'h36
`define  COLMOD_CMD 8'h3A
`define PORCTRL_CMD 8'hB2
`define   GCTRL_CMD 8'hB7
`define   VCOMS_CMD 8'hBB
`define LCMCTRL_CMD 8'hC0
`define FRCTRL2_CMD 8'hC6
`define   INVON_CMD 8'h21
`define  DISPON_CMD 8'h29
`define   CASET_CMD 8'h2A
`define   RASET_CMD 8'h2B
`define   RAMWR_CMD 8'h2C
`define SWRESET_CMD 8'h01
`define  SLPOUT_CMD 8'h11
`define   NORON_CMD 8'h13

`define LONG_DLY_MSB 7
`define SHORT_DLY_MSB 6
`define LONG_DLY (8'b1 << `LONG_DLY_MSB) // 200 ms
`define SHORT_DLY (8'b1 << `SHORT_DLY_MSB) //  10 ms
`define DISP_WIDTH 8'h87
`define DISP_HEIGHT 8'hF0

`ifdef FPGA
   `define CLKFREQ 13.5*1000000
   `define LONG_DLY_CYCLES 0.2*`CLKFREQ // 200ms
   `define SHORT_DLY_CYCLES 0.01*`CLKFREQ // 10ms
   `define HWRST_CYCLES 0.00002*`CLKFREQ // 20us
`else
   `define LONG_DLY_CYCLES 50
   `define SHORT_DLY_CYCLES 10
   `define HWRST_CYCLES 4
`endif

`endif // LCD_ST7789V3_VH

