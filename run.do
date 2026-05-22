vlib work
vmap work work

vlog +incdir+RTL TB/tb_intr_cntrlr.v
vsim -novopt -suppress 12110 tb +testname=unique_priority
add wave -position insertpoint -radix hex sim:/tb/dut/*
run -all
