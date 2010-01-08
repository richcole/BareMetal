#include<stdio.h>

int main()
{
	unsigned long i, j, maxn=1000000, primes=0;

	for(i=0; i<=maxn; i++)
	{
		for(j=2; j<=i-1; j++)
		{
			if(i%j==0) break; //Number is divisble by some other number. So break out
		}
		if(i==j)
		{
//			printf("%d ",i); //Number was divisible by itself (that is, i was same as j)
			primes = primes + 1;
		}
	} //Continue loop up to max number

	printf("%u Primes detected.", primes);
	printf("\n"); 
	return 0;
}
