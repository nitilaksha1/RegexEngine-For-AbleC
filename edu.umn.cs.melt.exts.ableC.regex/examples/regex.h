#ifndef REGEX__H
#define REGEX__H

#include "dfa.h"
#include <assert.h>
#include <string.h>
#include <stdlib.h>

/*
typedef struct matchInfo {

	int startindex;
	int matchlength;
	int nextpos;
	eBool matchfound;
} matchInfo;
*/

int test_full_string (struct DFA * dfa, char * str) {
	state state1 = get_start_state(dfa);
	input in = str[0];
	int i = 0;

	while (str[i++] != '\0') {
		state1 = (dfa->trans_table)[state1][in];

		if (state1 == -1)
			break;

		in = str[i];
	}

	if (is_final_state(dfa, state1) == TRUE)
		return 1;
	else
		return 0;
}

/*
eBool test_string_prefix (struct DFA * dfa, char * str) {
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

matchInfo match_prefix (struct DFA * dfa, char * str)
{
	state state = get_start_state(dfa);
	int len = strlen(str);
	input in;
	int i = 0;
	int startPos=0;
	int endPos=0;
	matchInfo minfo;
	
	while((in = str[i])!= '\0')
	{
		state = (dfa->trans_table)[state][in];

		if (state == -1)
			break;

		if (is_final_state(dfa, state) == TRUE)
			endPos=i;

		i++;
	}

	if(endPos==0) {
		minfo.startindex = -1;
		minfo.matchlength = -1;
		minfo.matchfound = FALSE;
		minfo.nextpos = -1;
		
		return minfo;
	}
	else
	{
		int size=endPos-startPos+1;
		minfo.startindex = startPos;
		minfo.matchlength = size;
		minfo.nextpos = -1;
		minfo.matchfound = TRUE;
		
		return minfo;
	}
}

matchInfo match_anywhere (struct DFA * dfa, char * str)
{
	state state = get_start_state(dfa);
	int len = strlen(str);
	input in;
	int i = 0;
	int startMatchPos=0;
	int endMatchPos=0;
	int checkPos=0;
	int matchFound=0;
	matchInfo minfo;

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
	
	matchInfo res;

	if(endMatchPos == 0)
	{
		res.startindex = -1;
		res.matchlength= -1;
		res.nextpos = endMatchPos + 1;
		res.matchfound = FALSE;
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
		res.matchfound = TRUE;
		res.startindex = startMatchPos;
		res.matchlength = prefixSize;
		res.nextpos = endMatchPos + 1;
		
		return res;
	}
}
*/
#endif
