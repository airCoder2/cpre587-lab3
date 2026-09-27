#include <iostream>
#include "Types.h"

#ifdef ZEDBOARD
#include "xparameters.h"
#include "xllfifo_hw.h" 
#endif

constexpr uint32_t RLR_PARTIAL = 0x80000000U;
const uintptr_t base = XPAR_AXI_FIFO_0_BASEADDR;

// Reads one full packet (handles cut-through partials too)
static void read_packet(uintptr_t base) {
    while (true) {
        while (Xil_In32(base + XLLF_RDFO_OFFSET) == 0);   // wait for data

        uint32_t rlr   = Xil_In32(base + XLLF_RLF_OFFSET);
        uint32_t bytes = rlr & 0x7FFFFFFFU;

        for (uint32_t i = 0; i < bytes; i += 4) {
            int32_t recv_data = (int32_t)Xil_In32(base + XLLF_RDFD_OFFSET);
            std::cout << "recv_data = " << recv_data << '\n';
        }

        if (!(rlr & RLR_PARTIAL)) break;   // packet complete
    }
}

void run_tests(){
    // Use these imports to access the Xilinx library functions and definitions
    // These are necessary for interfacing with your hardware
    // But do note, these cannot be found when compiling for the Lab computer
    // Send all data here, each write is sending 32-bits concatenated index and width
    //
    // Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + 0x38, 0xF);
    
    // first one is the bias
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0064); // load 100
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x010A); 
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x020A); 
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x030A); 
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x040A); 
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x050A); 
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x060A); 
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x070A); 
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x080A); 
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TLF_OFFSET, 4 * 9);

    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0060); // load 96
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0109); 
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TLF_OFFSET, 8);

    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x000A); // load 10
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TDFD_OFFSET, 0x0104); 
    Xil_Out32(XPAR_AXI_FIFO_0_BASEADDR + XLLF_TLF_OFFSET, 8);

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
    //
    const int NUM_RESULTS = 3;
    for (int p = 0; p < NUM_RESULTS; ++p) {
        std::cout << "result " << p << ":\n";
        read_packet(base);
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

