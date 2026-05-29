#Design file is included in tb file,
#but design file is inside RTL folder,
#so,to compile file inside folder use +incdir+(foldername)
#and also,folder in which TB file is located

vlog +incdir+RTL TB/tb_intr_cntrlr.v
vsim -novopt -suppress 12110 tb +testname=unique_priority
add wave -position insertpoint -radix hex sim:/tb/dut/*
run -all
