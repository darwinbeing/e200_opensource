
library      ?= work
toplevel     ?= tb
src-list     := tb.list
src_vhd-list := tb_vhd.list
src          := $(shell xargs printf '\n%s' < $(src-list)  | cut -b 1-)
src_vhd      := $(shell xargs printf '\n%s' < $(src_vhd-list)  | cut -b 1-)
compile_flag_vhd += +cover+/dut -64 -nologo
compile_flag += +cover+/dut -incr -64 -nologo
sim_opts     += -64 -coverage -classdebug -voptargs="+acc"
questa_version ?= ${QUESTASIM_VERSION}
incdir       += ../../install/rtl/core

build: clean
	vlib${questa_version} $(library)
	vcom${questa_version} -work $(library) -pedanticerrors $(src_vhd) $(compile_flag_vhd)
	vlog${questa_version} -work $(library) -pedanticerrors $(src) $(compile_flag) +incdir+$(incdir) +incdir+hdl
	touch $(library)/.build

# this starts modelsim with gui
sim: build
	vsim${questa_version} -lib $(library) $(toplevel) -do "do wave.do" $(sim_opts)

# batch mode without gui
simc: build
	vsim${questa_version} -lib $(library) $(toplevel) -c -do "run -all; exit" $(sim_opts)

clean:
	rm -rf $(library)

.PHONY: clean simc sim build
