#include <stdio.h>
#include "dfa.h"
#include "regex.h"
#include <ctype.h>

char * populateStr (const char * str, char * s) {
	strcpy (s, str);

	return s;
}

int main (int argc, char **argv) 
{
	//char *var="abbaabbd";
	char * str = (char *)malloc(sizeof(char) * 9);

	if((populateStr("abbaabbd", str)) =~/(a|b)*abb/)
		printf("MATCH\n");
	else
		printf("NO MATCH\n");

	char *tar="abbaabb";
	if(tar =~/(a|b)*abb/)
		printf("MATCH\n");
	else
		printf("NO MATCH\n");
	return 0;
}