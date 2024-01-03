import cocotb
from cocotb_bus.drivers import BusDriver
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from collections import deque

data_link = deque()

class BOWDriver(BusDriver):
    _optional_signals = ('txclk', 'presetn')
    _signals = ('pwdata_tx', 'fec_in', 'aux_in', 'psel_tx', 'penable_tx', 'pwrite_tx', 'data_link')

    def __init__(self, dut, data, clk, sb_callback):
        BusDriver.__init__(self, dut, data, clk)  
        self.bus.pwdata_tx = data
        self.bus.data_link = data_link
        self.callback = sb_callback
        self.txclk = clk

    async def _driver_write(self, data, sync=True):
        data = data(data)
        pass

    async def _driver_read(self, value, sync=True):
        for i in range(32):
            data_link.append(self.bus.data_link.value)
            self.callback(self.bus.data_link.value, data_link)
            await RisingEdge(self.txclk)
        pass

class BOWconfig(BusDriver):  
    _signals = ('penable_tx', 'pwrite_tx', 'data_link')
    _optional_signals = ('txclk', 'presetn')

    def __init__(self, dut, data, clk):
        BusDriver.__init__(self, dut, data, clk)
        self.txclk = clk

    async def _driver_config(self, value, sync=True):
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
        await RisingEdge(self.bus.txclk)
        self.bus.psel_tx.value = 1
        await RisingEdge(self.bus.txclk)
        self.bus.penable_tx.value = 1
        await RisingEdge(self.bus.txclk)
        self.bus.pwrite_tx.value = 1
        await RisingEdge(self.bus.txclk)
        pass

