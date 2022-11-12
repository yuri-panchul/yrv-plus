# gtkwave::loadFile "dump.vcd"

set all_signals [list]

lappend all_signals tb_yrv_mcu.i_yrv_mcu.
lappend all_signals tb_yrv_mcu.i_yrv_mcu.aux_uart_byte_data
lappend all_signals tb_yrv_mcu.i_yrv_mcu.aux_uart_byte_valid
lappend all_signals tb_yrv_mcu.i_yrv_mcu.aux_uart_rx
lappend all_signals tb_yrv_mcu.i_yrv_mcu.boot_address
lappend all_signals tb_yrv_mcu.i_yrv_mcu.boot_address_narrow
lappend all_signals tb_yrv_mcu.i_yrv_mcu.boot_busy
lappend all_signals tb_yrv_mcu.i_yrv_mcu.boot_data
lappend all_signals tb_yrv_mcu.i_yrv_mcu.boot_error
lappend all_signals tb_yrv_mcu.i_yrv_mcu.boot_valid
lappend all_signals tb_yrv_mcu.i_yrv_mcu.bufr_done
lappend all_signals tb_yrv_mcu.i_yrv_mcu.bufr_empty
lappend all_signals tb_yrv_mcu.i_yrv_mcu.bufr_full
lappend all_signals tb_yrv_mcu.i_yrv_mcu.bufr_ovr
lappend all_signals tb_yrv_mcu.i_yrv_mcu.bus_32
lappend all_signals tb_yrv_mcu.i_yrv_mcu.clk
lappend all_signals tb_yrv_mcu.i_yrv_mcu.debug_mode
lappend all_signals tb_yrv_mcu.i_yrv_mcu.ei_req
lappend all_signals tb_yrv_mcu.i_yrv_mcu.io_rd_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.io_wr_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.ld_wdata
lappend all_signals tb_yrv_mcu.i_yrv_mcu.li_req
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mcu_rdata
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mem_addr
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mem_addr_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mem_ble
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mem_ble_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mem_lock
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mem_rdata
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mem_rd_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mem_ready
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mem_trans
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mem_wdata
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mem_write
lappend all_signals tb_yrv_mcu.i_yrv_mcu.mem_wr_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.nmi_req
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port0_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port10_dec
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port1_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port2_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port32_dec
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port3_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port4_in
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port4_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port54_dec
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port5_in
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port5_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port6_reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port76_dec
lappend all_signals tb_yrv_mcu.i_yrv_mcu.port7_dat
lappend all_signals tb_yrv_mcu.i_yrv_mcu.rd_rdata
lappend all_signals tb_yrv_mcu.i_yrv_mcu.reg
lappend all_signals tb_yrv_mcu.i_yrv_mcu.resetb
lappend all_signals tb_yrv_mcu.i_yrv_mcu.rx_rdata
lappend all_signals tb_yrv_mcu.i_yrv_mcu.ser_clk
lappend all_signals tb_yrv_mcu.i_yrv_mcu.ser_rxd
lappend all_signals tb_yrv_mcu.i_yrv_mcu.ser_txd
lappend all_signals tb_yrv_mcu.i_yrv_mcu.wfi_state

set num_added [ gtkwave::addSignalsFromList $all_signals ]

gtkwave::/Time/Zoom/Zoom_Full
