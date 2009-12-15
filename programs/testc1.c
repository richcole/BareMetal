// gcc -o testc1.o -c testc1.c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer
// ld -T app.ld -o testc1.app testc1.o

void b_print_string(const char *string);
unsigned char b_input_wait_for_key(void);

int main(void)
{
	unsigned char tchar;
	
	b_print_string("Hello world, from C!\nHit a key: ");
	tchar = b_input_wait_for_key();
	
	if (tchar == 0x61)
	{
		b_print_string("key was 'a'\n");
	}
	else
	{
		b_print_string("key was not 'a'\n");
	}

	return 0;
}


// C call to os_print_string
// C passes the string address in RDI instead of RSI
void b_print_string(const char *string)
{
	asm ("xchg %rsi, %rdi");
	asm ("call 0x00100010"); // Do a call so it returns back
	asm ("xchg %rsi, %rdi");
}

// C call to os_input_key_wait
unsigned char b_input_wait_for_key(void)
{
	unsigned char temp = 0;
	asm ("call 0x00100038");
	asm ("mov %0, %%al" :"=r"(temp)); // Return the value in AL
	return temp;
}
