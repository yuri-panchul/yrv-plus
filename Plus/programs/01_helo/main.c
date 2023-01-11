#include "memory_mapped_registers.h"
#include <stdint.h>

#define LED_0   0xe
#define LED_1   0xd
#define LED_2   0xb
#define LED_3   0x7

#define HEX_H   0b11001000
#define HEX_E   0b10110000
#define HEX_L   0b11110001
#define HEX_O   0b10000001

uint32_t clock;

void sleep(){
        for(int i=0;i <100; i++) {
                clock++;
        }
}

void clean() {
        port0 =0xff;
	port1 =0xf;
}

void H() {
        port1 = LED_3;
        port0 = HEX_H;
        sleep();
        clean();
}

void E()
{
        port1 = LED_2;
        port0 = HEX_E;
        sleep();
        clean();
}

void L() {
        port1 = LED_1;
        port0 = HEX_L;
        sleep();
        clean();
}

void O() {
        port1 = LED_0;
        port0 = HEX_O;
        sleep();
        clean();
}

void HELO(int state) {
        if(state > 50000) H();
        if(state > 40000) E();
        if(state > 30000) L();
        if(state > 20000) O();
}

int next(int prev, int step){
        if(prev > 70000) prev=0;
        return prev + step;
}

void main(){
        clean();
        int state = 0;
        int step = 3;
        while(1){       
                HELO(state);        
                state = next(state,step);                
        }
}

