#include "memory_mapped_registers.h"
#include <stdint.h>
#include <coremark.h>

#define LED_0   0xe
#define LED_1   0xd
#define LED_2   0xb
#define LED_3   0x7

#define HEX_H   0b11001000
#define HEX_E   0b10110000
#define HEX_L   0b11110001
#define HEX_O   0b10000001

/*
0x00010000 port0 = {8'bxxxxxxxx, RDP, RA, RB, RC, RD, RE, RF, RG}
0x00010002 port1 = {4'bxxxx, C46, C45, C43, C42, 4'bxxxx, AN4, AN3, AN2, AN1}
0x00010004 port2 = L[16:1]
0x00010006 port3 = {CLR_EI, 1'bx, INIT, ECALL, NMI, LINT, INT, EXCEPT, L[24:17]}
0x00010008 port4 = DIP[16:1]
0x0001000a port5 = {C9, C8, C6, S5, S4, S3, S2, S1, DIP[24:17]}
0x0001000c port6 = {DIV_RATE, S_RESET, 3'bxxx}
0x0001000e port7 = {4'bxxxx, EMPTY, DONE, FULL, OVR, SER_DATA}
*/

uint32_t clock;

void sleep();

void long_sleep();

void very_long_sleep();


void clean();

void H();

void E();

void L();

void O();

void HELO(int state);

int next(int prev, int step);

void itoa(int, char *);

void beep();

void __attribute__((optimize("O0"))) say_serial_a();

void __attribute__((optimize("O0"))) say_lpt_a();

void plot(int x, int y, char color);
void line_slow(int x1, int y1, int x2, int y2, char color);
short time();

void cls();
void rainbow();

int clofk=0;
char  *VGA=(char *)0xA0000000L;

void main() {

    clean();
    very_long_sleep();
    int state = 0;
    int step = 3;
    int num = 65536;
        cls();
        rainbow();

        very_long_sleep();


        for (int c = 0; c < 256; c++) {
            for (int x = 0; x < 320; x++) {
                for (int y = 0; y < 240; y = y + 10) {
                    plot(x, y, c);
                }
            }
            for (int x = 0; x < 320; x = x + 10) {
                for (int y = 0; y < 240; y++) {
                    plot(x, y, c);
                }
            }
            for (int y = 0; y < 240; y++) {
                plot(319, y, c);
            }
            for (int x = 0; x < 320; x++) {
                plot(x, 239, c);
            }
            very_long_sleep();
        }
//
//    for (int x = 0; x < 159; x++) {
//            plot(x,0, 0xff);
//    }

    ;



//    ee_printf("\\nHello world!!!\n");
//    beep();
//    ee_printf("         time  %lu\n", time());
//    ee_printf("         time  %lu\n", time());
//    ee_printf("\f");





    while (1) {
        if (state == step) {
            beep();
            // say_lpt_a();
        }
        HELO(state);
        state = next(state, step);
    }
}

void cls() {
    for (int x = 0; x < 320; x++) {
        for (int y = 0; y < 240; y++) {
            plot(x,y, 0);
        }
    }
}

void rainbow() {
    for (int x = 0; x < 320; x++) {
        for (int y = 0; y < 240; y++) {
            plot(x,y, y);
        }
    }
}

int
abs (int i) {
    return i < 0 ? -i : i;
}

int sgn(int x) {
    if (x==0) return 0;
    else if (x>0) return 1;
    else
        return -1;
}

void plot(int x, int y, char color) {
    VGA[(y<<8) + (y<<6) + x] = color;
}


void line_slow(int x1, int y1, int x2, int y2, char color)
{
    int dx,dy,sdx,sdy,px,py,dxabs,dyabs,i;
    int slope;

    dx=x2-x1;      /* the horizontal distance of the line */
    dy=y2-y1;      /* the vertical distance of the line */
    dxabs=abs(dx);
    dyabs=abs(dy);
    sdx=sgn(dx);
    sdy=sgn(dy);
    if (dxabs>=dyabs) /* the line is more horizontal than vertical */
    {
        slope=(int)dy / (int)dx;
        for(i=0;i!=dx;i+=sdx)
        {
            px=i+x1;
            py=slope*i+y1;
            plot(px,py,color);
        }
    }
    else /* the line is more vertical than horizontal */
    {
        slope=(int)dx / (int)dy;
        for(i=0;i!=dy;i+=sdy)
        {
            px=slope*i+x1;
            py=i+y1;
            plot(px,py,color);
        }
    }
}

void sleep() {
    for (int i = 0; i < 100; i++) {
        clock++;
    }
}

void long_sleep() {
    for (int i = 0; i < 2000; i++) {
        clock++;
    }
}

void very_long_sleep() {
    for (int i = 0; i < 60000; i++) {
        asm("nop");
    }
}


void clean() {
    port0 = 0xff;
    port1 = 0xf;
    port3 = 0x01;
}

void H() {
    port1 = LED_3;
    port0 = HEX_H;
    sleep();
    clean();
}

void E() {
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
    if (state > 50000) H();
    if (state > 40000) E();
    if (state > 30000) L();
    if (state > 20000) O();
}

int next(int prev, int step) {
    if (prev > 60000) prev = 0;
    return prev + step;
}

void beep() {
    for (short i = 0; i < 100; i++) {
        port2 = 0xff00;
        long_sleep();
        port2 = 0x0000;
        long_sleep();
    }
}

short time() {
    return port5;
}