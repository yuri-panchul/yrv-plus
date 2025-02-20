// https://www.dcs.gla.ac.uk/~jhw/cordic/
// https://www.dcs.gla.ac.uk/~jhw/cordic/cordic-32bit.h

#define M_PI 3.1415926536
#define cordic_1K 0x26DD3B6A
#define half_pi 0x6487ED51
#define MUL 1073741824.000000f
#define CORDIC_NTAB 32

int cordic_ctab[] = {
    0x3243F6A8,
    0x1DAC6705,
    0x0FADBAFC,
    0x07F56EA6,
    0x03FEAB76,
    0x01FFD55B,
    0x00FFFAAA,
    0x007FFF55,
    0x003FFFEA,
    0x001FFFFD,
    0x000FFFFF,
    0x0007FFFF,
    0x0003FFFF,
    0x0001FFFF,
    0x0000FFFF,
    0x00007FFF,
    0x00003FFF,
    0x00001FFF,
    0x00000FFF,
    0x000007FF,
    0x000003FF,
    0x000001FF,
    0x000000FF,
    0x0000007F,
    0x0000003F,
    0x0000001F,
    0x0000000F,
    0x00000008,
    0x00000004,
    0x00000002,
    0x00000001,
    0x00000000,
};

void cordic(int theta, int *s, int *c, int n)
{
    int k, d, tx, ty, tz;
    int x = cordic_1K, y = 0, z = theta;
    n = (n > CORDIC_NTAB) ? CORDIC_NTAB : n;
    for (k = 0; k < n; ++k)
    {
        d = z >> 31;
        // get sign. for other architectures, you might want to use the more portable version
        // d = z>=0 ? 0 : -1;
        tx = x - (((y >> k) ^ d) - d);
        ty = y + (((x >> k) ^ d) - d);
        tz = z - ((cordic_ctab[k] ^ d) - d);
        x = tx;
        y = ty;
        z = tz;
    }
    *c = x;
    *s = y;
}



void cordic_grad(int grad, int *sin, int *cos)
{
    float p = grad * 3.14159265f / 180;
    cordic((p * MUL), sin, cos, 32);
}

float sin(int g)
{
    int s, c;
    int grad = g % 360;
    int c_grad = grad;
    if (grad > 90 && grad <= 180)
    {
        c_grad = 180 - grad;
    }

    if (grad > 180 && grad <= 270)
    {
        c_grad = grad - 180;
    }
    if (grad > 270 && grad <= 380)
    {
        c_grad = 360 - grad;
    }

    cordic_grad(c_grad, &s, &c);
    float sn = s / MUL;

    if (grad > 180 && grad <= 360)
    {
        sn = sn * (-1.0f);
    }
    return sn;
}

float cos(int g)
{
    int s, c;
    int grad = g % 360;
    int c_grad = grad;
    if (grad > 90 && grad <= 180)
    {
        c_grad = 180 - grad;
    }

    if (grad > 180 && grad <= 270)
    {
        c_grad = grad - 180;
    }
    if (grad > 270 && grad <= 380)
    {
        c_grad = 360 - grad;
    }

    cordic_grad(c_grad, &s, &c);
    float cs = c / MUL;

    if (grad > 180 && grad <= 360)
    {
        cs = cs * (-1.0f);
    }
    return cs;
}

float tan(int g)
{
    int s, c;
    int grad = g % 360;
    int c_grad = grad;
    if (grad > 90 && grad <= 180)
    {
        c_grad = 180 - grad;
    }

    if (grad > 180 && grad <= 270)
    {
        c_grad = grad - 180;
    }
    if (grad > 270 && grad <= 380)
    {
        c_grad = 360 - grad;
    }

    cordic_grad(c_grad, &s, &c);
    int cs = c;
    int sn = s;

    if (grad > 180 && grad <= 360)
    {
        sn = sn * (-1.0f);
    }

    if (grad > 180 && grad <= 360)
    {
        cs = cs * (-1.0f);
    }
    return cs == 0 ? 0 : (float)sn / cs;
}