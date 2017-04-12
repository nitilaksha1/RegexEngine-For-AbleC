// File demonstrating the generated C code for 'StringPrefixWithMatchReturned.xc'

#include<stdio.h>
#include "dfa.h"
#include "regex.h"

extern void init_DFA (struct DFA *, state, int);
extern void add_trans (struct DFA *, state, state, input);
extern void set_final_state (struct DFA *, state);
extern eBool match_prefix (struct DFA *, char *);
extern void release_DFA (struct DFA *);

int main (int argc, char ** argv) {
  
  // dfa1 replaces reg1
  struct DFA dfa;

  /* auto-generated dfa for regex "(a|b)*abb"  */
  init_DFA (&dfa, 0, 4);
  set_final_state (&dfa, 3);
  add_trans (&dfa, 0, 1, 'a');
  add_trans (&dfa, 0, 0, 'b');
  add_trans (&dfa, 1, 1, 'a');
  add_trans (&dfa, 1, 2, 'b');
  add_trans (&dfa, 2, 1, 'a');
  add_trans (&dfa, 2, 3, 'b');
  add_trans (&dfa, 3, 1, 'a');
  add_trans (&dfa, 3, 0, 'b');
  
  char *text1 = "abaabbabbababc";  /* good case to match */
  char *text2 = "ababcabababb"; /* bad case to match */

  // Matching the text against the regex1
  // Note that the regex got replaced by the dfa
  char *res1 = match_prefix_return(&dfa, text1);
  if(res1)
  {
    printf("\nThe longest matched prefix is: %s", res1);
  }
  else
  {
    printf("\nNo match found ");
  }

  free(res1);
  
  // Matching the text2 against the regex
  // Note that the regex got replaced by the dfa
  char *res2 = match_prefix_return(&dfa, text2);
  if(res2)
  {
    printf("\nThe longest matched prefix is: %s", res2);
  }
  else
  {
    printf("\nNo match found ");
  }

  free(res2);

  release_DFA (&dfa);
  return 0;
}
