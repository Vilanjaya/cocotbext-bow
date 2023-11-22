import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ReadOnly
from cocotb_bus.drivers import BusDriver
from cocotb_coverage.coverage import CoverCross, CoverPoint, coverage_db
from cocotb_bus.monitors import BusMonitor
from collections import deque
import random
import os

data = deque()
fec = deque()
aux = deque()
data_tx = deque()
fec_tx = deque()
aux_tx = deque()

def sb_fn():
    data.pop()
    fec.pop()
    aux.pop()
    for i in range(31):
        assert data_tx.pop() == data.pop(), "Data Scoreboard Matching Failed"
        assert fec_tx.pop() == fec.pop(), "Fec Scoreboard Matching Failed"
        assert aux_tx.pop() == aux.pop(), "Aux Scoreboard Matching Failed"

# Corrected coverpoint definition
@CoverPoint("top.fec_in",  # noqa F405
            xf=lambda x, y: x,
            bins=list(range(2))
            )
@CoverPoint("top.aux_in",  # noqa F405
            xf=lambda x, y: y,
            bins=list(range(2))
            )
@CoverCross("top.cross.ab",
            items=["top.fec_in",
                   "top.aux_in"
                   ],
            ign_bins=[(0, 1)]
            )
def ab_cover(fec_in,aux_in):
	pass
	
	
@CoverPoint("top.pwrite_tx",	# noqa F405
			xf=lambda x: x,  
            bins=list(range(2)),
            )
def din_value_cover(value):
    pass


    
@cocotb.test()
async def Bow_system_test(dut):
    for i in range(50):
        preset_drv = PresetDriver(dut, dut.pclk_tx)
        await preset_drv._driver_send(0)
        dataMonitor(dut, None, dut.pclk_tx, callback=None)

    
        #dataMonitor(dut, None, dut.txclk, callback=None)
        #print(data_tx,data)
        write_drv = GranuleWriteDriver(dut, dut.pclk_tx)
        await write_drv._driver_send(0)

        for i in range(100):
            await RisingEdge(dut.pclk_tx)

    sb_fn()

    data.clear()
    fec.clear()
    aux.clear()
    data_tx.clear()
    fec_tx.clear()
    aux_tx.clear()
        
    coverage_db.report_coverage(cocotb.log.info, bins=True)
    coverage_file = os.path.join(
        os.getenv('RESULT_PATH', "./"), 'coverage.xml')
    coverage_db.export_to_xml(filename=coverage_file)

class PresetDriver(BusDriver):
    _signals = ['presetn', 'fec_in', 'aux_in', 'psel_tx', 'penable_tx', 'pwrite_tx', 'pwdata_tx', 'pclk_tx']

    def __init__(self, dut, clk):
        BusDriver.__init__(self, dut, None, clk)
        self.bus.presetn.setimmediatevalue(1)

    async def _driver_send(self, value, sync=True):
        await RisingEdge(self.bus.pclk_tx)
        self.bus.presetn.value = 0
        self.bus.fec_in.value = 0
        self.bus.aux_in.value = 0
        self.bus.psel_tx.value = 0
        self.bus.penable_tx.value = 0
        self.bus.pwrite_tx.value = 0
        self.bus.pwdata_tx.value = 0
        await FallingEdge(self.bus.pclk_tx)
        await Timer(50, 'ns')
        self.bus.presetn.value = 1


class GranuleWriteDriver(BusDriver):
    _signals = ['presetn', 'fec_in', 'aux_in', 'psel_tx', 'penable_tx', 'pwrite_tx', 'pwdata_tx', 'pclk_tx']
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
        await RisingEdge(self.bus.pclk_tx)
        self.bus.psel_tx.value = 1
        await RisingEdge(self.bus.pclk_tx)
        self.bus.penable_tx.value = 1
        await RisingEdge(self.bus.pclk_tx)
        self.bus.pwrite_tx.value = 1
        for i in range(32):
            data = random.randint(0, 65535)
            if self.count_transitions((self.var & 0xFFFF), data) > 8:
                self.bus.pwdata_tx.value = ~data & 0xFFFF
                self.bus.aux_in.value = 1
            else:
                self.bus.pwdata_tx.value = data & 0xFFFF
                self.bus.aux_in.value = 0
            aux_tx.append(self.bus.aux_in.value)
            ab_cover(self.bus.fec_in.value,self.bus.aux_in.value)
            din_value_cover(self.bus.pwrite_tx.value)
            self.var = self.bus.pwrite_tx.value
            data_tx.append(self.bus.pwdata_tx.value)
            self.bus.fec_in.value = self.fec_logic(data & 0xFFFF)
            fec_tx.append(self.bus.fec_in.value)
            await RisingEdge(self.bus.pclk_tx)
        await RisingEdge(self.bus.pclk_tx)


class dataMonitor(BusMonitor):
    _signals = ['presetn', 'fec_in', 'aux_in', 'psel_tx', 'penable_tx', 'pwrite_tx', 'pwdata_tx', 'pclk_tx', 'pwrite_rx', 'data_link', 'fec_link', 'aux_link']

    async def _monitor_recv(self):
        risingedge = RisingEdge(self.bus.pclk_tx)
        rdonly = ReadOnly()
        flag = 0
        while True:
            await risingedge
            await rdonly
            if self.bus.pwrite_rx == 1 and flag == 0:
                flag=1
                for i in range(32):
                    data.append(self.bus.data_link.value)
                    fec.append(self.bus.fec_link.value)
                    aux.append(self.bus.aux_link.value)
                    await risingedge
                    await rdonly
        


# You may need to continue the implementation of the missing classes (GranuleWriteDriver, PresetDriver, and IO_Monitor) or import them correctly from external modules.

# As for the covergroup and coverage checking, you can uncomment and complete the relevant parts later in your code once you define the covergroup classes properly.

# Also, make sure to properly connect the 'dut.pclk' and 'dut.txclk' signals to your design.


