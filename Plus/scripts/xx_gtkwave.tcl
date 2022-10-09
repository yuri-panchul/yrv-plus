# gtkwave::loadFile "dump.vcd"

set all_signals [list]

lappend all_signals tb.clk
lappend all_signals tb.reset_n
lappend all_signals tb.key_sw
lappend all_signals tb.i_top.led
lappend all_signals tb.i_top.abcdefgh
lappend all_signals tb.i_top.digit
lappend all_signals tb.i_top.buzzer
lappend all_signals tb.i_top.vsync
lappend all_signals tb.i_top.hsync
lappend all_signals tb.i_top.rgb

set num_added [ gtkwave::addSignalsFromList $all_signals ]

gtkwave::/Time/Zoom/Zoom_Full
