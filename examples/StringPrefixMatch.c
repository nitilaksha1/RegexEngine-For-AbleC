// File demonstrating the generated C code for 'StringPrefixMatch.xc'

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
  
  char *text1 = "abaabbababc";  /* good case to match */
  char *text2 = "ababcabababb"; /* bad case to match */

  // Matching the text against the regex1
  // Note that the regex got replaced by the dfa
  if (match_prefix(&dfa, text1) == TRUE) 
  {
    printf("text1 matches regex(correct)\n");
  } 
  else 
  {
    printf("text1 does not match regex(incorrect)\n");
  }
  
  // Matching the text2 against the regex
  // Note that the regex got replaced by the dfa
  if (match_prefix(&dfa, text2) == TRUE) {
    printf("text2 matches regex(incorrect)\n");
  } 
  else 
  {
    printf("text2 does not match regex(correct)\n");
  }

  release_DFA (&dfa);

  return 0;
}
