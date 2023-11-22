import cocotb
from cocotb.triggers import RisingEdge, ReadOnly, NextTimeStep, Timer, FallingEdge
from cocotb_bus.drivers import BusDriver
from cocotb_coverage.coverage import CoverCross, CoverPoint, coverage_db
from cocotb_bus.monitors import BusMonitor
import os
import random

@cocotb.test()
async def lfsr_test(dut):
	await RisingEdge(dut.clk)
	dut.reset_n.value = 0
	await RisingEdge(dut.clk)
	dut.reset_n.value = 1
	counter=0;
	counter1=0;
	x=0;
	z=0;
	
	for i in range(100):
		await RisingEdge(dut.clk)
		x=dut.y.value
		await FallingEdge(dut.clk)
		z=dut.y.value
		for j in range(1,16):
			if(x[j]^z[j]==1):
				counter=counter+1;
		counter=0;
		

