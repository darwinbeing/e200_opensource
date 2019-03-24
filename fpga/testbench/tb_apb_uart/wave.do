onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TB /tb/stim_start
add wave -noupdate -group TB /tb/stim_end
add wave -noupdate -group TB /tb/end_of_sim
add wave -noupdate -group TB /tb/acq_done
add wave -noupdate -group TB /tb/mem_rand_en
add wave -noupdate -group TB /tb/inv_rand_en
add wave -noupdate -group TB /tb/io_rand_en
add wave -noupdate -group TB /tb/tlb_rand_en
add wave -noupdate -group TB /tb/exception_en
add wave -noupdate -group TB /tb/stim_vaddr
add wave -noupdate -group TB /tb/exp_data
add wave -noupdate -group TB /tb/exp_vaddr
add wave -noupdate -group TB /tb/stim_push
add wave -noupdate -group TB /tb/stim_flush
add wave -noupdate -group TB /tb/stim_full
add wave -noupdate -group TB /tb/exp_empty
add wave -noupdate -group TB /tb/exp_pop
add wave -noupdate -group TB /tb/dut_out_vld
add wave -noupdate -group TB /tb/dut_in_rdy
add wave -noupdate -group TB /tb/clk
add wave -noupdate /tb/clk
add wave -noupdate /tb/rst_n
add wave -noupdate /tb/icb_cmd_valid
add wave -noupdate /tb/icb_cmd_ready
add wave -noupdate /tb/icb_cmd_addr
add wave -noupdate /tb/icb_cmd_read
add wave -noupdate /tb/icb_cmd_wdata
add wave -noupdate /tb/icb_cmd_wmask
add wave -noupdate /tb/icb_rsp_valid
add wave -noupdate /tb/icb_rsp_ready
add wave -noupdate /tb/icb_rsp_rdata
add wave -noupdate /tb/icb_rsp_err
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {213 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 208
configure wave -valuecolwidth 77
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2220 ps}
