import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb_bus.drivers import BusDriver
from cocotb_coverage.coverage import CoverCross, CoverPoint, coverage_db
from cocotb_bus.monitors import BusMonitor
import random
import os


@cocotb.test()
async def Bow_rx_test(dut):
    preset_drv = PresetDriver(dut, dut.pclk)
    await preset_drv._driver_send(0)
    arr = [32766,16946,21704,14394,5767,28072,430,20082,21801,26229,17508,60020,21695,39807,57723,53525,64846,38159,5158,32769,18240,33820,21395,42124,6293,51278,16460,64253,778,15556,31434,32620,15589]
    fec_in_arr = [0,1,0,1,1,0,0,0,1,1,1,1,0,0,0,1,1,0,1,0,1,1,0,0,0,1,0,1,0,1,1,1,1]
    aux_in_arr = [0,1,0,1,0,1,1,0,1,1,1,1,0,1,0,1,1,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0]
    for _ in range(100):
        await RisingEdge(dut.clk_pos)

    for i in range(0,32,2):
        await RisingEdge(dut.clk_pos)
        dut.prdata.value = arr[i]
        dut.fec_in.value = fec_in_arr[i]
        dut.aux_in.value = aux_in_arr[i]
        await FallingEdge(dut.clk_pos)
        dut.prdata.value = arr[i+1]
        dut.fec_in.value = fec_in_arr[i+1]
        dut.aux_in.value = aux_in_arr[i+1]

    for _ in range(200):
        await RisingEdge(dut.clk_pos)

    preset_drv = PresetDriver(dut, dut.pclk)
    await preset_drv._driver_send(0)

    for _ in range(100):
        await RisingEdge(dut.clk_pos)

    for i in range(0,32,2):
        await RisingEdge(dut.clk_pos)
        dut.prdata.value = arr[i]
        dut.fec_in.value = fec_in_arr[i]
        dut.aux_in.value = aux_in_arr[i]
        await FallingEdge(dut.clk_pos)
        dut.prdata.value = arr[i+1]
        dut.fec_in.value = fec_in_arr[i+1]
        dut.aux_in.value = aux_in_arr[i+1]
    
    for _ in range(200):
        await RisingEdge(dut.clk_pos)



class PresetDriver(BusDriver):
    _signals = ['fec_in','aux_in', 'prdata', 'presetn', 'pready', 'psel', 'penable', 'pwrite', 'data_link', 'fec_link', 'aux_link', 'rx_ready', 'pclk', 'clk_pos', 'clk_neg']

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
        self.bus.data_link.value = 0
        self.bus.rx_ready.value = 0
        await Timer(7,'ns')
        self.bus.presetn.value = 1
        await Timer(3,'ns')
        self.bus.prdata.value = 34944
        await Timer(5,'ns')
        self.bus.prdata.value = 17472
        await Timer(5,'ns')
        self.bus.prdata.value = 8736
        await Timer(5,'ns')
        self.bus.prdata.value = 4368
        await Timer(5,'ns')
        self.bus.prdata.value = 34952
        await Timer(5,'ns')
        self.bus.prdata.value = 50244
        await Timer(5,'ns')
        self.bus.prdata.value = 40413
        #await Timer(100,'ns')


    



        

