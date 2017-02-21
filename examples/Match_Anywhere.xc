// This file demonstrates the use of =# operator which checks whether the prefix of a string conforms to the regex 
// It returns the longest prefix match if the regex matches a prefix of the string.
// It returns false in all other cases

#include<stdio.h>

int main (int argc, char ** argv) {
  
  const char *text1 = "zabdaababbzzababbz";  /* good case */
  const char *text2 = "ababcabababz"; /* bad case */

  regex_t reg = "(a|b)*abb"; /* regex used for matching */

  // Matching the text1 against the regex
  MAS s1 = (text1=@reg);
  while (s1.matched)
  {
    printf("Matched string: %s", s1.match);
    s1 = (rest=@reg);
  }

    // Matching the text1 against the regex
  MAS s2 = (text2=@reg);
  while (s2.matched)
  {
    printf("Matched string: %s", s2.match);
    s2 = (rest=@reg);
  }

  return 0;
}