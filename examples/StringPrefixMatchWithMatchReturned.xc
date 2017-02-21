// This file demonstrates the use of =# operator which checks whether the prefix of a string conforms to the regex 
// It returns the longest prefix match if the regex matches a prefix of the string.
// It returns false in all other cases

#include<stdio.h>

int main (int argc, char ** argv) {
  
  const char *text1 = "abaabbabbababc";  /* good case */
  const char *text2 = "ababcabababb"; /* bad case */

  regex_t reg = "(a|b)*abb"; /* regex used for matching */

  // Matching the text1 against the regex
  char *res1 = (text1=#reg);
  if(!res1)
    printf("The longest matched prefix is: %s", res1);
  else
    printf("No match found ");
  
  // Matching the text2 against the regex
  char *res2 = (text2=#reg);
  if(!res2)
    printf("The longest matched prefix is: %s", res2);
  else
    printf("No match found ");
    
  return 0;
}