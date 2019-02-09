## project-dependent parameters
## design name

## bitstream file
set BITFILE  $env(FPGA_DIR)/obj/system.bit

## server setup (local machine)
set SERVER   localhost
set PORT     3121

## connect to the server
open_hw
connect_hw_server -url ${SERVER}:${PORT} -verbose
puts "Current hardware server set to [get_hw_servers]"

## specify target FPGA
## manually
#current_hw_target  [get_hw_targets */xilinx_tcf/Digilent/210249854623]

## automatically
open_hw_target
current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]

set_property PROGRAM.FILE $BITFILE [lindex [get_hw_devices] 0]

## download the firmware to target external memory
program_hw_devices  [lindex [get_hw_devices] 0]

## close target
close_hw_target

## terminate the connection when done
disconnect_hw_server  [current_hw_server]

## close hardware
close_hw
