# BOW (Bunch Of Wires) Documentation

  

BOW is a versatile module designed to handle data transmission through a network of wires. This documentation provides a detailed overview of the various components, functionalities, and best practices for integrating BOW into your projects.

# Table of Contents

 1. Bow_tx 
 2. Bow_rx 
 3. Bow_system Linear Feedback Shift Register (LFSR)
 4. Cocotb Testbench for Bow_rx 
 5. Cocotb Testbench for Bow_system Cocotb
 6. Test for I2C Write Functionality 
 7. Constraint Module 
 8. Cocotb Framework for LFSR Behavior Verification 
 9. Makefile (Bow_test, lfsr_test,Bow_rx_test, Bow_system_test)

**Getting Started**

Prerequisites

  

- Verilog simulator (e.g., Icarus Verilog)
- Cocotb for testbench development

  

**Installation**

 
**Clone the repository**: 

    git clone https://github.com/Vilanjaya/BOW.git`

**Python Version: Make sure you have Python 3.x installed. You can download Python from the official**

    sudo apt install python3.8

**Package Installation:**

After installing Python, open a terminal or command prompt and use pip to install the required Python packages. In this case, you'll need to install cocotb, cocotb_bus, and cocotb_coverage. Run the following commands:

    pip install cocotb
    pip install cocotb_bus
    pip install cocotb_coverage

**Other Dependencies:**

The collections, random, and os modules are part of the Python standard library, so you don't need to install them separately.

**Run Tests:**

  

Once you have the necessary packages installed, you can run your tests. Usually, testbenches in Cocotb are run using a simulator like ModelSim or VCS. Make sure your simulator is properly installed and configured.

  

**Activate Virtual Environment (Optional):**

  

If you're using a virtual environment, activate it before running the tests. See the previous response for instructions on creating and activating a virtual environment.

  

**Run Tests (Command Line):**

Depending on your project structure, you might run your tests from the command line. To use these modules, import the one you need and connect it to the DUT. The typical command is:

  

    from hdl.bow_run import  BOWDriver, BOWConfig

  

Make sure to consult the documentation of Cocotb and your simulator for any simulator-specific instructions.

  

**virtual environments to manage your project dependencies:**

  

    python -m venv venv

  

**Activate the virtual environment:**

  

*On Windows:*

  

    .\venv\Scripts\activate

  

*On Linux/macOS:*

  

    source venv/bin/activate

  

After activating the virtual environment, you can install the required packages using pip install

  # Example Interface**

Sample Interface

  

    import asyncio
    from cocotbext.bow import BOWDriver, BOWConfig

    async def run_test():
        bow = BOWDriver(dut, data, pclk_tx, sb_callback)
        
    for _ in range(32):
        await bow._driver_write(0x0000)
        await bow._driver_write.wait()
        
    async def cb(txn):
        data = txn['data']
        print(f"Received data in callback: {data}")

    bow.set_callback(cb)

    rdata = await bow._driver_read()

    try:
        bow.regress()
    except Exception as e:
        cocotb.log.info("Regression failed: %s" % str(e))
        
    asyncio.run(run_test())

# Usage

***1. Bow_tx***

**Inputs:**

*presetn: Active-low asynchronous preset. 
txclk: Transmit clock. 
fec_in: Forward error correction input. 
aux_in: Auxiliary input. 
psel, penable, pwrite: Control signals for the internal state machine. 
pwdata: Data to be written into the internal memory. 
rx_ready: Signal indicating whether the receiver is ready to receive data.*

**Outputs:**

*pclk: Divided transmit clock 
prdata: Data to be read by the receiver. 
fec_out, aux_out: Outputs corresponding to FEC  and auxiliary data. 
pready: Output indicating that the transmitter is ready for the next operation. 
clk_pos, clk_neg: Signals indicating the positive and negative edges of the transmit clock.*

**Internal Signals:**

*Various registers (mem, fec_reg, aux_reg, state, addr, addrx, count, count1, idle, setup, access, complete, clkd, pstate, sent_to_rx, sent_to_rx_enable, preset_flag, preset_flag_flag). lfsr_out: Output from the linear feedback shift register (LFSR).*

**Internal Modules:**

*An instance of an LFSR module named lfsr.*
		
**Functionality:**

*The module has an internal state machine (idle, setup, access, complete) that controls the data transmission process.
It uses an LFSR  for  PRBS generation.
The module interacts with an internal memory (mem) for storing data to be transmitted.
The rx_ready signal controls the data transmission process, ensuring that it only transmits when the receiver is ready.*

**Initial Block:**

*Initializes some internal signals and memory during the initial simulation time.*

**Always Blocks:**

*There are several always blocks that trigger on either the positive or negative edge of the transmit clock or the pclk signal.*

**Sequential and Combinational Logic:**


*The design uses both sequential (always @(posedge txclk)) and combinational (always @(posedge pclk)) logic.*

  
**2. Bow_rx**


**Module Declaration:**

*The module is named Bow_rx.
It has various inputs (fec_in, aux_in, prdata, clk_pos, clk_neg, presetn) and outputs (pready, psel, penable, pwrite, data_link, fec_link, aux_link, rx_ready, pclk).*

**Internal Signals:**

*clkd: A 3-bit register used as a clock divider.
lfsr_out: A 16-bit wire representing the output of a Linear Feedback Shift Register (LFSR).
pstate: A 3-bit register representing the state of the state machine.
state, idle, setup, access, complete: 3-bit registers representing different states of the state machine.
fec_reg, aux_reg: 2-bit registers representing arrays used as memory for  FEC  and  AUX data.
mem: A 16-bit array representing memory.
addr: A 6-bit register used for addressing memory.
mem_full: A 1-bit register indicating whether the memory is full.
count: A 6-bit register used as a counter.
j and i: Integer counters used in loops.
ps, ns, idle1, setup1, dat_capture: 2-bit registers and counters used in a second state machine.*

**Initial Block:**

*Initializes various signals to zero.
Always Block (Clock Divider):
Divides the positive clock (clk_pos) to generate a divided clock (pclk).*

LFSR Module:

*An instantiation of an LFSR module with inputs (clk, reset_n) and an output (lfsr_out).*

Always Block (State Machine Logic):

*Determines the next state (pstate) based on the positive clock edge and the reset condition (presetn).*

Always Block (Access and Control Logic):

*Controls the state transitions and memory access based on the positive clock edge and the divided clock (pclk).*

Second State Machine:

*Another state machine implemented using the signals ps and ns.
Manages transitions between the states idle1, setup1, and dat_capture.
Captures data (prdata) when certain conditions are met and updates memory.*

**3. Bow_system**

Module Declaration

*The module is named Bow_system.
It has various inputs (presetn, txclk, fec_in, aux_in, psel_tx, penable_tx, pwrite_tx, pwdata_tx) and outputs (pclk_tx, pready_rx, psel_rx, penable_rx, pwrite_rx, data_link, fec_link, aux_link, pclk_rx, prdata).*

Internal Signals

*fec_out, aux_out: Wires used to connect the outputs of the transmitter to the receiver.
pready_tx, clk_pos, clk_neg: Wires used to connect various signals between the transmitter and receiver.
rx_ready: A wire used to connect the rx_ready signal from the receiver to the transmitter.*

Transmitter Instantiation (Bow_tx)

*The transmitter (Bow_tx) is instantiated with various input  and output connections.
The instantiation includes connecting signals like presetn, txclk, fec_in, aux_in, etc., from the Bow_system module to the corresponding inputs of the transmitter.
The transmitter outputs (fec_out, aux_out, pready_tx, clk_pos, clk_neg) are connected to the corresponding wires in the Bow_system module.
rx_ready is connected from the receiver to the transmitter.*

Receiver Instantiation (Bow_rx)

*The receiver (Bow_rx) is instantiated with various input  and output connections.
The instantiation includes connecting signals like fec_out, aux_out, prdata, etc., from the Bow_system module to the corresponding inputs of the receiver.
The receiver outputs (pready_rx, psel_rx, penable_rx, pwrite_rx, data_link, fec_link, aux_link, pclk_rx) are connected to the corresponding outputs in the Bow_system module.
rx_ready is connected from the receiver to the transmitter.*

 
**4. Linear Feedback Shift Register (LFSR)**

Module Declaration

*This Verilog module implements a Linear Feedback Shift Register (LFSR) with a configurable number of bits (N).
The LFSR  is used as a pseudorandom number generator and includes a function to count the number of bit toggles between consecutive states.*

Internal Signal

*yreg and xreg: Registers of width N+1 used to store the current and previous states of the LFSR.*

Initial Block

*Initializes y to '1' at the beginning.*

Always Block (Sequential Logic)

*The LFSR state is updated on each positive clock edge (posedge clk) and negative clock edge (negedge clk), as well as on a negative reset edge (negedge reset_n).
The LFSR  is designed to XOR specific bits based on the feedback polynomial, and the new state is determined using these XOR operations.
The toggle_count function is called to count the number of bit toggles between the current and previous states.
If the toggle count is greater than 7, the LFSR output y is inverted; otherwise, y retains its current value.*

Toggle Count Function

*The toggle_count function calculates the number of bit toggles between two states (x and y).
It iterates through each bit and increments the count if the corresponding bits in x and y differ.*

Note

*The LFSR  is commonly used for generating pseudorandom sequences in digital systems.
The polynomial used for feedback in this LFSR  is determined by the XOR operations in the yreg assignment.*

**5. Cocotb Testbench for Bow_system**

Cocotb Test Function (Bow_test)

*The main test function initializes a PresetDriver and sends a preset signal to the Bow_system module.
It then uses a GranuleWriteDriver to perform a write operation and monitors the coverage of the signals.
The testbench performs this operation in a loop and reports coverage.*

PresetDriver Class

*A custom BusDriver class  for driving signals to the Bow_system module.
The _driver_send method sends a preset signal to the Bow_system module.*

GranuleWriteDriver Class

*A custom BusDriver class  for driving signals related to granule data to the Bow_system module.
The _driver_send method writes granule data to the Bow_system module.*

Scoreboard Function (sb_fn)

*A function that asserts the actual value against the expected value to check if the scoreboard matches.*

Coverage Function (ab_cover and din_value_cover)

*Functions defining coverage points and crosses for various signals.*

Timing Delays

*Delays are introduced using Timer and RisingEdge to synchronize with the clock.*

Coverage Reporting

*The coverage points are reported and exported to an XML file.*

**6. Cocotb Testbench for Bow_rx**

Cocotb Test Function (Bow_rx_test)

*This test function initializes drivers for various inputs to the Bow_rx module.
It performs read and write operations, monitors signals, and checks for correct functionality.
The testbench is designed to simulate different scenarios and edge cases.*

DataLinkDriver Class

*A custom BusDriver class  for driving signals related to data link to the Bow_rx module.
The _driver_send method simulates the data link behavior in the Bow_rx module.*

FecLinkDriver Class

*A custom BusDriver class  for driving signals related to FEC link to the Bow_rx module.
The _driver_send method simulates the FEC link behavior in the Bow_rx module.*

AuxLinkDriver Class

*A custom BusDriver class  for driving signals related to auxiliary link to the Bow_rx module.
The _driver_send method simulates the auxiliary link behavior in the Bow_rx module.*

Monitor Function (monitor_rx)

*A function that monitors the signals and records their values for analysis.*

Coverage Function (cover_rx_signals)

*A function that defines coverage points for various signals in the Bow_rx module.*

Timing Delays

*Delays are introduced using Timer and RisingEdge to synchronize with the clock.*

Assertions

*Assertions are used to check if the expected behavior matches the actual behavior.*

Coverage Reporting

*The coverage points are reported and exported to an XML file.*

**7. Cocotb Testbench for Bow_system**

Cocotb Test Function (Bow_test)

*The Bow_test function serves as the main test scenario for the Bow_system module.
It initializes a PresetDriver and sends a preset signal to the Bow_system module.
The testbench then utilizes a GranuleWriteDriver to perform a write operation and monitors the coverage of the signals.
The entire operation is conducted in a loop, and coverage is reported.*

PresetDriver Class

*This is a custom BusDriver class designed to drive signals to the Bow_system module.
The _driver_send method in this class sends a preset signal to the Bow_system module.*

GranuleWriteDriver Class

*A custom BusDriver class that handles signals related to granule data for the Bow_system module.
The _driver_send method writes granule data to the Bow_system module.*

Scoreboard Function (sb_fn)

*The sb_fn function is responsible for asserting the actual value against the expected value to verify if the scoreboard matches.*

Coverage Function (ab_cover and din_value_cover)

*Functions that define coverage points and crosses for various signals in the Bow_system module.
These functions contribute to coverage analysis, providing insights into the extent of simulation coverage.*

Timing Delays

*Delays are introduced using Timer and RisingEdge to synchronize with the clock.
These delays ensure that signals stabilize before being sampled.*

Coverage Reporting

*The coverage points are reported and exported to an XML file.
Coverage reporting is a crucial aspect of the testbench, providing insights into how well the design has been exercised during simulation.*

**Cocotb Testbench for the Bow_system Module
Cocotb Test Function (Bow_system_test)**

Description:

*Initializes a PresetDriver to send a preset signal to the Bow_system module.
Monitors data transmission using a DataMonitor.
Utilizes a GranuleWriteDriver to write granule data to the Bow_system module.
Performs these operations in a loop.
Verifies data using a Scoreboard function (sb_fn).
Reports and exports coverage to an XML file.*

Classes:

*PresetDriver: Custom BusDriver class  for sending preset signals.
GranuleWriteDriver: Custom BusDriver class  for driving granule data.
DataMonitor: Custom BusMonitor class  for monitoring signals during data transmission.*

Functions:

*sb_fn: Compares transmitted data, FEC, and auxiliary signals with expected values.
cover_rx_signals: Defines coverage points and crosses for fec_in and aux_in signals.*

Timing:

*Delays introduced using Timer and RisingEdge for clock synchronization.*

Coverage Reporting:

*Coverage points reported and exported to an XML file.*


**8.Cocotb Test Function (Bow_test)**

 
Description:

*Initializes a PresetDriver to send a preset signal to the Bow_system module.
Uses a GranuleWriteDriver to perform a write operation.
Monitors coverage of signals.
Operates in a loop and reports coverage.*

Classes:

*PresetDriver: Custom BusDriver class  for sending preset signals.
GranuleWriteDriver: Custom BusDriver class  for driving granule data.*

Functions:

*sb_fn: Asserts actual value against expected value for scoreboard matching.
ab_cover and din_value_cover: Functions defining coverage points and crosses for various signals.*

Timing:

*Delays introduced using Timer and RisingEdge for clock synchronization.*

Coverage Reporting:

*Coverage points reported and exported to an XML file.*

**9.Cocotb Test for Testing I2C Write Functionality**

  
I2cMaster Instance:

*Created using cocotbext.i2c to simulate I2C transactions.*

Device Address and Data:

*device_address: Set to 0x50 (I2C device address).
data_to_write: Bytearray containing the data to be written*.

I2C Write:

*await i2c.write(device_address, data_to_write): Performs an I2C write operation.*

Note:

*None values indicate no separate signals for  SDA  and  SCL assertions.
Uncommented line related to clock configuration (#cocotb.start_soon(Clock(dut.scl_rx, 10, units="ns").start())).*

Constraint Module

Variables:

*length: Represents the total length of the packet (range: 64 to 1500  bytes).
hdrlength: Represents the header length (14  or  16  bytes).
payloadlength: Represents the payload length (50 to 1486  bytes).
type: Represents the packet type (0x800 to 0x806).
hasVLAN: Represents whether the packet has a VLAN tag (True  or  False).*

Constraints:

*length == hdrlength + payloadlength: Ensures total length equals the sum of header and payload lengths.
hdrlength ==  16  if hasVLAN else hdrlength ==  14: Header length is  16  if the packet has a VLAN tag; otherwise, it's 14.
length ==  64  if  type  ==  0x806  else  True: Ensures total length is  64  if packet type  is  0x806.*

Printing Solutions:

*Uses p.getSolutions() to obtain all solutions to the Constraint Satisfaction Problem (CSP).
Cocotb Framework to Verify the Behavior of an LFSR*

Initialization:

*Begins with a rising edge on the clock, asserts reset_n low, and follows with another rising edge.*

Reset:

*De-asserts reset_n high.
Initializes a counter and variables.
Clock Edges Loop:
Iterates for  100 cycles.
Captures values of dut.y on each rising and falling edge.
Compares bits of x and z on each iteration.
Increments a counter based on XOR results.*


Makefile:

*Defines variables, targets, and rules for simulation using Icarus Verilog.
Includes necessary Cocotb Makefile rules.*


## Contributing

We welcome contributions! Read the contribution guidelines for more information.

## Contribution Guidelines

### Getting Started

1.  Fork the repository on GitHub.
2.  Clone your forked repository to your local machine.
3.  Create a new branch for your changes.
4.  Make your changes and commit them with a descriptive commit message.
5.  Push your changes to your fork on GitHub.
6.  Open a pull request on the official BOW repository.

### Code Style

-   Follow the existing code style and structure in the project.
-   Use meaningful variable and function names.
-   Document your code thoroughly, especially for complex sections.

### Testing

-   Ensure your changes don't break existing tests.
-   Add new tests for any new functionality.

### Commit Guidelines

-   Use clear and concise commit messages.
-   Prefix your commit messages with the relevant type:
    -   `feat`: for new features
    -   `fix`: for bug fixes
    -   `docs`: for documentation changes
    -   `test`: for adding tests
    -   `chore`: for routine tasks, maintenance, etc.

### Pull Request Guidelines

-   Provide a clear and descriptive title for your pull request.
-   Explain the purpose and scope of your changes in the description.
-   Reference any related issues in your pull request.

## License

This project is licensed under the MIT License.

  
## Acknowledgments

Special thanks to:

-  **[Vijayvithal Jahagirdar](https://github.com/jahagirdar):**  for mentoring and providing guidance throughout the development process 

-  **[Kishan S Murthy](https://www.linkedin.com/in/kishan-s-murthy-84797a212/):**  for collaborative efforts in building and contributing to the project.


