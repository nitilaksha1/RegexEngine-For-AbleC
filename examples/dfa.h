#ifndef DFA__H
#define DFA__H

#include <assert.h>
#include <string.h>
#include <stdlib.h>

#define CHARSET_SIZE 128
#define START_STATE 0
#define FINAL_STATE 3
#define DFA_SIZE 4

typedef int state;
typedef char input;
enum {NONE = -1};
typedef enum {FALSE = 0, TRUE}eBool;

struct DFA {

	state initial_state;
	int *final_state;
	int size;
	int **trans_table;
};

void init_DFA (struct DFA * dfa, state init_state, int size) {

	dfa->initial_state = init_state;
	dfa->final_state = (int *) malloc (size * sizeof(int));

	for (int i = 0; i < size; i++)
		dfa->final_state[i] = 0;

	dfa->size = size;

	dfa->trans_table = (int **)malloc(size * sizeof(int *));
    
    for (int i = 0; i < size; i++)
        (dfa->trans_table)[i] = (int *)malloc (CHARSET_SIZE * sizeof(int));
    
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < CHARSET_SIZE; j++) {
            (dfa->trans_table)[i][j] = NONE;
        }
    }
}

void set_final_state (struct DFA *dfa, int state) {
	dfa->final_state[state] = 1;
}

eBool is_legal_state (struct DFA * dfa, state st) {
	if ((int)st < 0 || st > (dfa->size - 1))
		return FALSE;

	return TRUE;
}

state get_start_state (struct DFA * dfa) {
	return dfa->initial_state;
}

eBool is_final_state (struct DFA * dfa, state st) {
	
	if (dfa->final_state[st] == 1)
		return TRUE;

	return FALSE;
}

void add_trans (struct DFA * dfa, state from, state to, input in) {

	assert (is_legal_state(dfa, from));
	assert (is_legal_state(dfa, to));

	(dfa->trans_table)[from][in] = to;
}

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

	if (is_final_state(dfa, state) == TRUE)
		return TRUE;
	else
		return FALSE;
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

void release_DFA (struct DFA * dfa) {
	free (dfa->trans_table);
}

#endif
