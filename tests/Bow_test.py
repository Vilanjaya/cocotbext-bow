import cocotb
from cocotb.triggers import RisingEdge, FallingEdge
from cocotb_bus.drivers import BusDriver
from cocotb_coverage.coverage import CoverCross, CoverPoint, coverage_db
from cocotb_bus.monitors import BusMonitor
import random
import os

def sb_fn(actual_value):
    global expected_value
    assert actual_value == expected_value.pop(0), "Scoreboard Matching Failed"

# Corrected coverpoint definition
@CoverPoint("top.penable",  # noqa F405
            xf=lambda x, y: x,
            bins=list(range(2))
            )
@CoverPoint("top.pready",  # noqa F405
            xf=lambda x, y: y,
            bins=list(range(2))
            )
@CoverCross("top.cross.ab",
            items=["top.penable",
                   "top.pready"
                   ],
            ign_bins=[(0, 1)]
            )
def ab_cover(penable,pready):
	pass
	
	
@CoverPoint("top.fec_out",	# noqa F405
			xf=lambda x: x,  
            bins=list(range(2)),
            )
def din_value_cover(value):
    pass
    
    
@cocotb.test()
async def Bow_test(dut):
    global data
    
    preset_drv = PresetDriver(dut, dut.pclk)
    await preset_drv._driver_send(0)
    #IO_Monitor(dut, None, dut.txclk, callback=a_prot_cover)
    
    write_drv = GranuleWriteDriver(dut, dut.pclk)
    await write_drv._driver_send(0)

    for i in range(100):
        await RisingEdge(dut.pclk)

    await preset_drv._driver_send(0)

    for i in range(100):
        await RisingEdge(dut.pclk)

    await write_drv._driver_send(0)

    for i in range(100):
        await RisingEdge(dut.pclk)
        
    coverage_db.report_coverage(cocotb.log.info, bins=True)
    coverage_file = os.path.join(
        os.getenv('RESULT_PATH', "./"), 'coverage.xml')
    coverage_db.export_to_xml(filename=coverage_file)


class PresetDriver(BusDriver):
    _signals = ['pclk', 'presetn', 'fec_in', 'aux_in', 'psel', 'penable', 'pwrite', 'pwdata', 'rx_ready']

    def __init__(self, dut, clk):
        BusDriver.__init__(self, dut, None, clk)
        self.bus.presetn.setimmediatevalue(1)

    async def _driver_send(self, value, sync=True):
        await RisingEdge(self.bus.pclk)
        self.bus.presetn.value = 0
        self.bus.fec_in.value = 0
        self.bus.aux_in.value = 0
        self.bus.psel.value = 0
        self.bus.penable.value = 0
        self.bus.pwrite.value = 0
        self.bus.pwdata.value = 0
        self.bus.rx_ready.value = 0
        await FallingEdge(self.bus.pclk)
        self.bus.presetn.value = 1


class GranuleWriteDriver(BusDriver):
    _signals = ['pclk', 'presetn', 'fec_in', 'aux_in', 'psel', 'penable', 'pwrite', 'pwdata', 'rx_ready', 'pready']
    var = 0x0000

    def __init__(self, dut, clk):
        BusDriver.__init__(self, dut, None, clk)

    def count_transitions(self, x, y):
        xor_result = x ^ y
        num_transitions = bin(xor_result).count('1')
        return num_transitions

    def fec_logic(self, binary_num):
        count_ones = sum(int(bit) for bit in bin(binary_num)[2:])
        if count_ones % 2 == 0:
            return 0
        else:
            return 1

    async def _driver_send(self, value, sync=True):
        await RisingEdge(self.bus.pclk)
        self.bus.rx_ready.value = 1
        self.bus.psel.value = 1
        await RisingEdge(self.bus.pclk)
        self.bus.penable.value = 1
        await RisingEdge(self.bus.pclk)
        self.bus.pwrite.value = 1
        for i in range(32):
            data = random.randint(0, 65535)
            if self.count_transitions((self.var & 0xFFFF), data) > 8:
                self.bus.pwdata.value = ~data & 0xFFFF
                self.bus.aux_in.value = 1
            else:
                self.bus.pwdata.value = data & 0xFFFF
                self.bus.aux_in.value = 0
            ab_cover(self.bus.penable.value,self.bus.pready.value)
            self.var = self.bus.pwdata.value
            self.bus.fec_in.value = self.fec_logic(data & 0xFFFF)
            await RisingEdge(self.bus.pclk)
        await RisingEdge(self.bus.pclk)
        

# You may need to continue the implementation of the missing classes (GranuleWriteDriver, PresetDriver, and IO_Monitor) or import them correctly from external modules.

# As for the covergroup and coverage checking, you can uncomment and complete the relevant parts later in your code once you define the covergroup classes properly.

# Also, make sure to properly connect the 'dut.pclk' and 'dut.txclk' signals to your design.
