#include <stdio.h>
#include "dfa.h"
#include "regex.h"

int main (int argc, char **argv) 
{
	char *var="abbaabbd";
	if(var =~/(a|b)*abb/)
		printf("MATCH\n");
	else
		printf("NO MATCH\n");

	// 

	char *tar="abbaabb";
	if(tar =~/(a|b)*abb/)
		printf("MATCH\n");
	else
		printf("NO MATCH\n");
	return 0;
}