#include "memory_mapped_registers.h"

void main(){
        port0 =0xff;
	port1 =0xf;
    while(1) {
        port0 =0b00000001;
	port1 =0xe;
        port0 =0b01110001;
	port1 =0xd;
        port0 =0b00110000;
	port1 =0xb;
        port0 =0b01001000;
	port1 =0x7;

    } 
}
