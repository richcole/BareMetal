// gcc -o testc1.o -c testc1.c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer
// ld -T app.ld -o testc1.app testc1.o

void b_print_string(const char *str);
void b_print_char(const char chr);
unsigned char b_input_wait_for_key(void);
void b_int_to_string(unsigned long long nbr, char *str);
unsigned long long b_string_to_int(const char *str);

int main(void)
{
	unsigned char tchar = 0x65, tstring[25];
	unsigned long long tlonglong;
//	b_print_char(tchar);

	b_int_to_string(0xFFFFFFFFFFFFFFFF, tstring);
	b_print_string(tstring);
	tlonglong = b_string_to_int(tstring);

	b_print_string("Hello world, from C!\nHit a key: ");
	tchar = b_input_wait_for_key();
	
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
void b_print_string(const char *str)
{
	asm volatile ("call 0x00100010" : : "S"(str)); // Make sure string is passed in RSI
}

void b_print_char(const char chr)
{
	asm volatile ("call 0x00100018" : : "a"(chr));
}

// C call to os_input_key_wait
unsigned char b_input_wait_for_key(void)
{
	asm volatile ("call 0x00100038");
}

void b_int_to_string(unsigned long long nbr, char *str)
{
	asm volatile ("call 0x001000C0" : : "a"(nbr), "D"(str));
}

unsigned long long b_string_to_int(const char *str)
{
	asm volatile ("call 0x001000E0" : : "S"(str));
}
