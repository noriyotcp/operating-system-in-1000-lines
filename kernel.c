extern char __bss[], __bss_end[], __stack_top[];

void *memset(void *buf, char c, unsigned int n)
{
    unsigned char *p = (unsigned char *) buf;
    while (n--)
        *p++ = c;
    return buf;
}

void kernel_main(void) {
    memset(__bss, 0, (unsigned int) __bss_end - (unsigned int) __bss);

    for(;;);
}

__attribute__((section(".text.boot")))
__attribute__((naked))
void boot(void) {
    __asm__ __volatile__(
        "mv sp, %[stack_top]\n"
        "j kernel_main\n"
        :
        : [stack_top] "r" (__stack_top)
    );
}
