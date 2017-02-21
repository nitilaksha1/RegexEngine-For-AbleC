#ifndef REGEX__H
#define REGEX__H

#include "dfa.h"
#include <assert.h>
#include <string.h>
#include <stdlib.h>

typedef struct MAS {

	int matched;
	char *match;
	char *rest;
} MAS;

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

MAS match_anywhere(struct DFA * dfa, char * str)
{
	state state = get_start_state(dfa);
	int len = strlen(str);
	input in;
	int i = 0;
	int startMatchPos=0;
	int endMatchPos=0;
	int checkPos=0;
	int matchFound=0;
	

	while(str[checkPos]!='\0')
	{
		i=checkPos;
		state = get_start_state(dfa);

		if(matchFound)
			break;
		else
		{
			startMatchPos=checkPos;
			while((in = str[i])!= '\0')
			{
				state = (dfa->trans_table)[state][in];

				if (state == -1)
				{
					checkPos=checkPos+1;
					break;
				}

				if (is_final_state(dfa, state) == TRUE)
				{
					matchFound=1;

					endMatchPos=i;
				}

				i++;
			}	
		}	
	}
	
	MAS res;

	if(endMatchPos==0)
	{
		res.matched=0;
		res.match=NULL;
		res.rest=NULL;
		return res;
	}
	else
	{
		int prefixSize=endMatchPos-startMatchPos+1;
		int restSize=len-endMatchPos;
		char* prefixArray = (char *) malloc (prefixSize * sizeof(char));
		char* restArray = (char *) malloc (restSize * sizeof(char));	
		
		for(int i=startMatchPos, j=0;i<(prefixSize+startMatchPos) && j<prefixSize; i++, j++)
			prefixArray[j]=str[i];

		for(int i=endMatchPos+1, j=0; i<len && j<restSize;i++, j++)
			restArray[j]=str[i];
		//
		res.matched=1;
		res.match=prefixArray;
		res.rest=restArray;
		return res;
	}
}

#endif
