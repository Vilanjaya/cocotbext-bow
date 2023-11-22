SIM ?= icarus
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/wrappers/Bow_test.v
VERILOG_SOURCES += $(PWD)/../hdl/Bow_tx.v
VERILOG_SOURCES += $(PWD)/wrappers/lfsr_test.v
VERILOG_SOURCES += $(PWD)/../hdl/lfsr.v
VERILOG_SOURCES += $(PWD)/wrappers/Bow_rx_test.v
VERILOG_SOURCES += $(PWD)/../hdl/Bow_rx.v
VERILOG_SOURCES += $(PWD)/../hdl/Bow_system.v
VERILOG_SOURCES += $(PWD)/wrappers/Bow_system_test.v
#VERILOG_SOURCES += $(PWD)/../hdl/i2c_controller.v
all:lfsr bow_tx bow_rx bow_system
bow_tx:
	rm -rf sim_build
	$(MAKE) sim MODULE=Bow_test TOPLEVEL=Bow_test
	
bow_rx:
	rm -rf sim_build
	$(MAKE) sim MODULE=Bow_rx_test TOPLEVEL=Bow_rx_test
	
lfsr:
	rm -rf sim_build
	$(MAKE) sim MODULE=lfsr_test TOPLEVEL=lfsr_test

bow_system:
	rm -rf sim_build
	$(MAKE) sim MODULE=Bow_system_test TOPLEVEL=Bow_system_test
	
#controller:
#	rm -rf sim_build
#	$(MAKE) sim MODULE=controller_test TOPLEVEL=i2c_controller
include $(shell cocotb-config --makefiles)/Makefile.sim
#bow_tx lfsr bow_rx 