#include <stdio.h>

void dummyFunc(int a, char *b)
{
	printf("Hello, I got called !");
}

int main (int argc, char **argv) 
{
	const char *text="Test String";
	if(text =~ /a/)
		printf("IF is true");
	else
		printf("ELSE is true");

	return 0;
}

