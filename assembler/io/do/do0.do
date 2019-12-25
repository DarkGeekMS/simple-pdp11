
add wave -position end  sim:/main/clk
add wave -position end  sim:/main/bbus

add wave -position end  sim:/main/int
add wave -position end  sim:/main/int_address

add wave -position end  sim:/main/rst

add wave -position end  sim:/main/alu_mode
add wave -position end  sim:/main/alu_enable
add wave -position end  sim:/main/alu_out

add wave -position end  sim:/main/mar_enable_in
add wave -position end  sim:/main/mdr_enable_in
add wave -position end  sim:/main/mdr_enable_out
add wave -position end  sim:/main/ir_enable_in
add wave -position end  sim:/main/ir_reset
add wave -position end  sim:/main/flags_enable_in
add wave -position end  sim:/main/flags_enable_out
add wave -position end  sim:/main/flags_clr_carry
add wave -position end  sim:/main/flags_set_carry
add wave -position end  sim:/main/flags_enable_from_alu
add wave -position end  sim:/main/r_enable_in
add wave -position end  sim:/main/r_enable_out
add wave -position end  sim:/main/tmp0_enable_in
add wave -position end  sim:/main/tmp0_clr
add wave -position end  sim:/main/tmp1_enable_in
add wave -position end  sim:/main/tmp1_enable_out
add wave -position end  sim:/main/rd
add wave -position end  sim:/main/wr
add wave -position end  sim:/main/alubuffer_enable_out
add wave -position end  sim:/main/hlt_iterator
add wave -position end  sim:/main/itr_current_adr
add wave -position end  sim:/main/itr_next_adr
add wave -position end  sim:/main/mar_to_ram
add wave -position end  sim:/main/mdr_to_ram
add wave -position end  sim:/main/tmp0_to_alu
add wave -position end  sim:/main/ir_data_out
add wave -position end  sim:/main/flags_always_out
add wave -position end  sim:/main/alu_to_flags
add wave -position end  sim:/main/itr_out_inst
add wave -position end  sim:/main/ctrl_sigs
add wave -position end  sim:/main/num_iteration
add wave -position end  sim:/main/tmp1_clr
add wave -position end  sim:/main/r_clr
add wave -position end  sim:/main/ir_data_to_itr
add wave -position end  sim:/main/RAM_SIZE
add wave -position end  sim:/main/hlt


force -freeze sim:/main/clk 0 0, 1 {50 ns} -r 100
force -freeze sim:/main/int 0 0
force -freeze sim:/main/int_address 10'h000 0
noforce sim:/main/bbus
force -freeze sim:/main/rst 1 0
run
force -freeze sim:/main/rst 0 0
