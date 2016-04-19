network_x_size = 4
network_y_size = 4
wave_file = open('wave_'+str(network_x_size)+"x"+str(network_y_size)+'.do', 'w')


wave_file.write("onerror {resume}\n")
wave_file.write("quietly WaveActivateNextPane {} 0\n")
for i in range(0 , network_x_size*network_y_size):
	wave_file.write("add wave -noupdate -color green -radix decimal :tb_network_4x4:RX_L_"+str(i)+"\n")
wave_file.write("add wave -noupdate :tb_network_4x4:clk\n")
wave_file.write("add wave -noupdate :tb_network_4x4:clk\n")
for i in range(0 , network_x_size*network_y_size):
	wave_file.write("add wave -noupdate -color green -radix decimal :tb_network_4x4:TX_L_"+str(i)+"\n")
wave_file.write("add wave -noupdate :tb_network_4x4:clk\n")
wave_file.write("add wave -noupdate :tb_network_4x4:clk\n")
for i in range(0 , network_x_size*network_y_size):
	wave_file.write("add wave -noupdate -color Gold -radix decimal :tb_network_4x4:RX_L_"+str(i)+"\n")
	wave_file.write("add wave -noupdate -color Gold :tb_network_4x4:CTS_L_"+str(i)+"\n")
	wave_file.write("add wave -noupdate -color Gold :tb_network_4x4:DRTS_L_"+str(i)+"\n")
	wave_file.write("add wave -noupdate -color Violet -radix decimal :tb_network_4x4:TX_L_"+str(i)+"\n")
	wave_file.write("add wave -noupdate -color Violet :tb_network_4x4:RTS_L_"+str(i)+"\n") 
	wave_file.write("add wave -noupdate -color Violet :tb_network_4x4:DCTS_L_"+str(i)+"\n")
 	wave_file.write("add wave -noupdate :tb_network_4x4:clk\n")
wave_file.write("TreeUpdate [SetDefaultTree]\n")
wave_file.write("WaveRestoreCursors\n")
wave_file.write("quietly wave cursor active 0\n")
wave_file.write("configure wave -namecolwidth 396\n")
wave_file.write("configure wave -valuecolwidth 100\n")
wave_file.write("configure wave -justifyvalue left\n")
wave_file.write("configure wave -signalnamewidth 0\n")
wave_file.write("configure wave -snapdistance 10\n")
wave_file.write("configure wave -datasetprefix 0\n")
wave_file.write("configure wave -rowmargin 4\n")
wave_file.write("configure wave -childrowmargin 2\n")
wave_file.write("configure wave -gridoffset 0\n")
wave_file.write("configure wave -gridperiod 1\n")
wave_file.write("configure wave -griddelta 40\n")
wave_file.write("configure wave -timeline 0\n")
wave_file.write("configure wave -timelineunits ps\n")
wave_file.write("update\n")
wave_file.write("WaveRestoreZoom {0 ps} {147 ns}\n")