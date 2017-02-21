#ifndef REGEX__H
#define REGEX__H

#include "dfa.h"
#include <assert.h>
#include <string.h>
#include <stdlib.h>

eBool match (struct DFA * dfa, char * str) {
	state state = get_start_state(dfa);
	input in = str[0];
	int i = 0;

	while (str[i++] != '\0') {
		state = (dfa->trans_table)[state][in];

		if (state == -1)
			break;

		in = str[i];
	}

	if (is_final_state(dfa, state) == TRUE)
		return TRUE;
	else
		return FALSE;
}

eBool match_prefix (struct DFA * dfa, char * str) {
	state state = get_start_state(dfa);
	int len = strlen(str);
	unsigned prevstate;
	input in;
	int i = 0;

	while ((in = str[i])!= '\0') {
		prevstate = state;

		state = (dfa->trans_table)[state][in];

		if (state == -1)
			break;

		if (is_final_state(dfa, state) == TRUE)
			return TRUE;

		i++;
	}
	
	return FALSE;
}

char* match_prefix_return(struct DFA * dfa, char * str)
{
	state state = get_start_state(dfa);
	int len = strlen(str);
	input in;
	int i = 0;
	int startPos=0;
	int endPos=0;

	while((in = str[i])!= '\0')
	{
		state = (dfa->trans_table)[state][in];

		if (state == -1)
			break;

		if (is_final_state(dfa, state) == TRUE)
			endPos=i;

		i++;
	}

	if(endPos==0)
		return NULL;
	else
	{
		int size=endPos-startPos+1;
		char* res = (char *) malloc (size * sizeof(char));	
		for(int i=0;i<size;i++)
			res[i]=str[i];
		return res;
	}
}

/*eBool match_prefix (struct DFA * dfa, char * str) {
	state state = get_start_state(dfa);
	int len = strlen(str);
	int prevstate;
	int prelookahead;

	input in;
	int i = 0;

	while ((in = str[i])!= '\0') {
		prevstate = state;

		state = (dfa->trans_table)[state][in];

		if (is_final_state(dfa, state) == TRUE) {
			prelookahead = state;
			previ = i;

			j = i + 1;

			while ((in = str[j])!= '\0') {

				state = (dfa->trans_table)[state][in];

				if (is_final_state(dfa, state) == TRUE) {
					finalstatefound = TRUE;
					state = prelookahead;
					break;
				}

				if (state == -1) {
					invalidcharfound = TRUE;
					state = prelookahead;
					break;
				}

				j++;
			}

			if (finalsinvalidcharfound == TRUE)
				return TRUE;

			if (invalidcharfound == TRUE)


		}

		if (state == -1)
			break;

		i++;
	}

	if (i >=0 && i < len) {
		return is_final_state(dfa, prevstate);
	}

	if (is_final_state(dfa, state) == TRUE)
		return TRUE;
	else
		return FALSE;
}*/

#endif
