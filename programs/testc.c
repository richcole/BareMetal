// gcc -o testc.o -c testc.c -nostdlib -nostartfiles -nodefaultlibs
// -O2 -fomit-frame-pointer
// ld -T app.ld -o testc.bin testc.o
// Compile with gcc -O3 -fomit-frame-pointer -march=pentium4 -mfpmath=sse -msse2 -o fasta fasta.c

int main(void)
{
	char *str = "Hello world, from C!", *ch;
	unsigned short *vidmem = (unsigned short*) 0xb8000;
	unsigned i;

	for (ch = str, i = 0; *ch; ch++, i++)
		vidmem[i] = (unsigned char) *ch | 0x0700;

	return 0x12345678;
}

