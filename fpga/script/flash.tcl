## project-dependent parameters
## design name

## mcs file
set MCSFILE  $env(FPGA_DIR)/obj/system.mcs

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

## identify Quad SPI Flash memory (n25q128-3.3v-spi-x1_x2_x4 device)
# create_hw_cfgmem -hw_device [lindex [get_hw_devices] 0] -mem_dev  [lindex [get_cfgmem_parts {n25q128-3.3v-spi-x1_x2_x4}] 0]
create_hw_cfgmem -hw_device [lindex [get_hw_devices]  0] -mem_dev  [lindex [get_cfgmem_parts {mt25ql128-spi-x1_x2_x4}] 0]
set cfgmem [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0]]

set_property -dict {
	PROGRAM.BLANK_CHECK 0
	PROGRAM.ERASE 1
	PROGRAM.CFG_PROGRAM 1
	PROGRAM.VERIFY 1
	PROGRAM.CHECKSUM 0
} $cfgmem

refresh_hw_device [lindex [get_hw_devices] 0]

set_property -dict {
	PROGRAM.ADDRESS_RANGE {use_file}
	PROGRAM.PRM_FILE {}
	PROGRAM.UNUSED_PIN_TERMINATION {pull-none}
} $cfgmem

set_property PROGRAM.FILES [list $MCSFILE] [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0]]

## set programming options
#set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
#set_property PROGRAM.ERASE        1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
#set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
#set_property PROGRAM.VERIFY       1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
#set_property PROGRAM.CHECKSUM     0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
#refresh_hw_device [lindex [get_hw_devices xc7a100t_0] 0]

## programming file
# set_property PROGRAM.FILES ${MCSFILE} [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0]]
# set_property PROGRAM.ADDRESS_RANGE  {use_file} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
# set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
# set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
# set_property PROGRAM.ERASE        1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
# set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
# set_property PROGRAM.VERIFY       1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
#set_property PROGRAM.CHECKSUM     0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]

## download the firmware to target external memory
program_hw_devices  [lindex [get_hw_devices] 0]
# program_hw_cfgmem -hw_cfgmem [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
program_hw_cfgmem -hw_cfgmem $cfgmem

## close target
close_hw_target

## terminate the connection when done
disconnect_hw_server  [current_hw_server]

## close hardware
close_hw
