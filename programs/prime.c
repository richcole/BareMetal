// BareMetal compile
// gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -o prime.o prime.c -DBAREMETAL
// ld -T app.ld -o prime.app prime.o

// Linux compile
// gcc -m64 -fomit-frame-pointer -o prime prime.c -DLINUX

// maxn = 300000  primes = 25997
// maxn = 400000  primes = 33860
// maxn = 1000000 primes = 78498

#ifdef LINUX
#include <stdio.h>
#endif

#ifdef BAREMETAL
void b_print_string(char *str);
void b_int_to_string(unsigned long nbr, unsigned char *str);
#endif

int main()
{
	unsigned long i, j, maxn=300000, primes=0;
	unsigned char tstring[25];

	for(i=0; i<=maxn; i++)
	{
		for(j=2; j<=i-1; j++)
		{
			if(i%j==0) break; //Number is divisble by some other number. So break out
		}
		if(i==j)
		{
			primes = primes + 1;
		}
	} //Continue loop up to max number

#ifdef LINUX
	printf("%u", primes);
	printf("\n");
#endif

#ifdef BAREMETAL
	b_int_to_string(primes, tstring);
	b_print_string(tstring);
	b_print_string("\n");
#endif

	return 0;
}

#ifdef BAREMETAL
// C call to os_print_string
// C passes the string address in RDI instead of RSI
void b_print_string(char *str)
{
	asm volatile ("call 0x00100010" : : "S"(str)); // Make sure source register (RSI) has the string address (str)
}

void b_int_to_string(unsigned long nbr, unsigned char *str)
{
	asm volatile ("call 0x001000C0" : : "a"(nbr), "D"(str));
}
#endif

// EOF
