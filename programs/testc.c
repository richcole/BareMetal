// gcc -o testc.o -c testc.c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer
// ld -T app.ld -o testc.app testc.o

void b_print_string(const char *string);

int main(void)
{
	b_print_string("Hello world, from C!\n");
	return 0;
}


// C call to os_print_string
// C passes the string address in RDI instead of RSI
void b_print_string(const char *string)
{
	asm ("xchg %%rsi, %%rdi");
	asm ("call 0x00100010"); // Do a call so it returns back
	asm ("xchg %%rsi, %%rdi");
}
