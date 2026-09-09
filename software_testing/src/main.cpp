#include <iostream>
#include "Types.h"

void run_tests(){
	// TODO fill this out with software test for your MAC
}

#ifdef ZEDBOARD
i32 main() {
	std::cout << "Running on the ZEDBoard..." << std::endl;	
	run_tests();
	return 0;
}
#else
i32 main() {
	std::cout << "Running on the Lab computer..." << std::endl;
	run_tests();
	return 0;
}
#endif

