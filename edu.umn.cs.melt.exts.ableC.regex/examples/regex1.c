#include "dfa.h"
#include "regex.h"

extern void init_DFA (struct DFA *, state, int);
extern void add_trans (struct DFA *, state, state, input);
extern void set_final_state (struct DFA *, state);
extern eBool match (struct DFA *, char *);
extern void release_DFA (struct DFA *);

int main(int argc, char ** argv)
{

  const char *text = "abaabb";
  struct DFA dfa1;
  init_DFA (&dfa1, 1, 2);
  set_final_state(dfa1,0);
  add_trans(dfa1,1,0,'a');

  char text[50];
  printf("Enter a string: ");
  gets(text);

  if (match (&dfa1, text) == TRUE)
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
