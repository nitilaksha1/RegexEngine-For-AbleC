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

	// set all elements of final_state array to 0
	for (int i = 0; i < size; i++)
		dfa->final_state[i] = 0;

	dfa->size = size;

	dfa->trans_table = (int **)malloc(size * sizeof(int *));
    
    for (int i = 0; i < size; i++)
        (dfa->trans_table)[i] = (int *)malloc (CHARSET_SIZE * sizeof(int));
    
    // set all elements of trans_table array to NONE
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

void release_DFA (struct DFA * dfa) {
	free (dfa->final_state);
	free (dfa->trans_table);
}

#endif
