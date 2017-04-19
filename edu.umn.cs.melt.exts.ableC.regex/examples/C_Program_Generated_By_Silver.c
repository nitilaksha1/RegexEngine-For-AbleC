

#include <stdio.h>
#include "dfa.h"
#include "regex.h"

extern void init_DFA (struct DFA *, state, int);
extern void add_trans (struct DFA *, state, state, input);
extern void set_final_state (struct DFA *, state);
extern eBool match (struct DFA *, char *);
extern void release_DFA (struct DFA *);

int main(int argc, char ** argv)
{

	struct DFA dfa1;
	init_DFA (&dfa1, 4, 5);
	set_final_state(&dfa1,2);
	add_trans(&dfa1,1,0,'a');
	add_trans(&dfa1,1,1,'b');
	add_trans(&dfa1,2,0,'a');
	add_trans(&dfa1,2,1,'b');
	add_trans(&dfa1,3,0,'a');
	add_trans(&dfa1,3,2,'b');
	add_trans(&dfa1,0,0,'a');
	add_trans(&dfa1,0,3,'b');
	add_trans(&dfa1,4,0,'a');
	add_trans(&dfa1,4,1,'b');

	char text[50];
	printf("Enter a string: ");
	gets(text);

	if (test_full_string (&dfa1, text) == TRUE)
	{
		printf("text matches regex");
	}
	else
	{
		printf("text does not match first regex");
	}

	release_DFA (&dfa1);
	return 0;
}
