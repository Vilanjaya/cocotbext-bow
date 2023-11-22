import cocotb
from cocotb.triggers import RisingEdge, FallingEdge
from cocotb_bus.drivers import BusDriver
from cocotb_coverage.coverage import CoverCross, CoverPoint, coverage_db
from cocotb_bus.monitors import BusMonitor
import random
import os
import cocotbext.i2c import I2cMaster

@cocotb.test()
async def i2c_write_one_byte_test(dut):
	#cocotb.start_soon(Clock(dut.scl_rx, 10, units="ns").start())
	
    # Create an I2cMaster instance
    i2c = I2cMaster(None, dut.sda_rx, None, dut.scl_rx)

    # Define the I2C device's address
    device_address = 0x50

    # Data (one byte) to be written to the I2C device
    data_to_write = bytearray([0xAB])

    # Perform I2C write with one byte of data
    await i2c.write(device_address, data_to_write)
        
    
        
    
    	



