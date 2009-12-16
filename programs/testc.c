// gcc -o testc.o -c testc.c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer
// ld -T app.ld -o testc.bin testc.o

void b_print_string(const char *str);

int main(void)
{
	b_print_string("Hello world, from C!\n");

	return 0;
}


// C call to os_print_string
// C passes the string address in RDI instead of RSI
void b_print_string(const char *str)
{
	asm volatile ("call 0x00100010" :: "S"(str)); // Do a call so it returns back
}