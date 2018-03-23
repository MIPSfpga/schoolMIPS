
#define SIMULATION  0
#define HARDWARE    1

// config start

#define RUNTYPE     SIMULATION

// config end

#if     RUNTYPE == SIMULATION
    #define DELAY_VALUE    20
#elif   RUNTYPE == HARDWARE
    #define DELAY_VALUE    (10*1024*1024)
#endif

// GPIO peripharal registers
#define SM_GPIO_KEYS_ADDR    0x40000000
#define SM_GPIO_LEDS_ADDR    0x40000004

#define SM_GPIO_KEYS    (* (volatile unsigned *) SM_GPIO_KEYS_ADDR )
#define SM_GPIO_LEDS    (* (volatile unsigned *) SM_GPIO_LEDS_ADDR )

static void inline delay()
{
    long i;
    for (i=0; i < DELAY_VALUE ; i++);
}

int main ()
{
    for (;;)
    {
        int keys = SM_GPIO_KEYS;
        int leds = (keys << 1);
        SM_GPIO_LEDS = leds;
        delay();
    }

    return 0;
}
