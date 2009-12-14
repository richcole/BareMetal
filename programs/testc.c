// gcc -o testc.o -c testc.c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer
// ld -T app.ld -o testc.bin testc.o

void printstring(char *string);

int main(void)
{
	static char str[] = "Hello world, from C!";

	printstring(str);

	return 0;
}

// C call to os_print_string
// C passes the string address in RDI instead of RSI
void printstring(char *string)
{
	asm ("xchg %rsi, %rdi");
	asm ("jmp 0x00100010");
	asm ("xchg %rsi, %rdi");
}
