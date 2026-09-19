#include <iostream>
#include "Types.h"

#ifdef ZEDBOARD
#include "xparameters.h"
#include "xllfifo_hw.h" 
#endif

void run_tests(){
    // Use these imports to access the Xilinx library functions and definitions
    // These are necessary for interfacing with your hardware
    // But do note, these cannot be found when compiling for the Lab computer
    // Send all data here, each write is sending 32-bits concatenated index and width
    //
    
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + 0x38, 0x1);
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0064);
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TLF_OFFSET, 4);

    //Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + 0x38, 0x0);
    //Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0101);
    //Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0101);
    //Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0101);
    //Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0101);
    //Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0101);
    //Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0101);
    //Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0101);
    //Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0101);
    //// Set transmit length BEFORE writing the last word of the packet to the fifo
    //// to the total number of BYTES sent via the FIFO
    //Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TLF_OFFSET, 8*4);

    // To receive a packet:
    // Wait until we start receiving a packet (RX FIFO Occupancy is nonzero)
    while (Xil_In32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_RDFO_OFFSET) == 0);

    while (true) {
        // Then read how many words are available to us right now.
        // Bit 31 = 1 when this is all the words in the current packet
        // Bit 31 = 0 when this is how many words are available,
        // but no TLAST has been sent to us yet
        uint32_t read_len = Xil_In32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_RLF_OFFSET);
        // Read out every word we have access to right now

        for (int i = 0; i < (read_len & 0x7FFFFFFFUL); i+=4) {
            int32_t recv_data = (int32_t)Xil_In32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_RDFD_OFFSET);
            std::cout << "recv_data = " << recv_data << "\n" << std::endl;
        }

        if (!(read_len & (1 << 31))) {
            break; // This is all the data in this packet, done
        }
        // There is more in this data packet, wait for more to come in
    }
}

#ifdef ZEDBOARD
int main() {
	std::cout << "Running on the ZEDBoard...\n" << std::endl;	
	run_tests();
	std::cout << "Test DONE" << std::endl;	
	return 0;
}
#else
int main() {
	std::cout << "Running on the Lab computer..." << std::endl;
	run_tests();
	return 0;
}
#endif

