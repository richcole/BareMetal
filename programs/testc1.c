// gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -o testc1.o testc1.c
// ld -T app.ld -o testc1.app testc1.o

void b_print_string(char *str);
void b_print_char(char chr);
void b_print_newline(void);
unsigned char b_input_wait_for_key(void);
void b_int_to_string(unsigned long nbr, unsigned char *str);
unsigned long b_string_to_int(unsigned char *str);
unsigned long fib(unsigned int n);

int main(void)
{
	unsigned char tchar = 0x00, tstring[25];
	unsigned long tlong;

//	b_int_to_string(0xFFFFFFFFFFFFFFFF, tstring);
//	b_print_string(tstring);
//	b_print_newline();
//	tlong = b_string_to_int(tstring);
	tlong = fib(20);
	b_int_to_string(tlong, tstring);
	b_print_string(tstring);

	b_print_string("Hello world, from C!\nHit a key: ");
	tchar = b_input_wait_for_key();
	b_print_char(tchar);

	if (tchar == 'a')
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
void b_print_string(char *str)
{
	asm volatile ("call 0x00100010" : : "S"(str)); // Make sure source register (RSI) has the string address (str)
}

void b_print_char(char chr)
{
	asm volatile ("call 0x00100018" : : "a"(chr));
}

void b_print_newline(void)
{
	asm volatile ("call 0x00100028");
}

unsigned char b_input_wait_for_key(void)
{
	unsigned char chr;
	asm volatile ("call 0x00100038" : "=a" (chr));
	return chr;
}

void b_int_to_string(unsigned long nbr, unsigned char *str)
{
	asm volatile ("call 0x001000C0" : : "a"(nbr), "D"(str));
}

unsigned long b_string_to_int(unsigned char *str)
{
	unsigned long tlong;
	asm volatile ("call 0x001000E0" : "=a"(tlong) : "S"(str));
	return tlong;
}

unsigned long fib(unsigned int n)
{
	unsigned long a = 1, b = 1;
	unsigned long tmp;
	for (; n > 2; --n)
	{
		tmp = a;
		a += b;
		b = tmp;
	}
	return a;
}
