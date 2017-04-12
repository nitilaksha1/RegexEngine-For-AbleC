// This file demonstrates the use of =~ operator which checks whether a string conforms to the regex 
// It returns true if the regex matches the full string
// It returns false in all other cases

#include<stdio.h>

int main (int argc, char ** argv) {
  
  const char *text = "abaabb";  /* text to match */

  regex_t reg1 = "(a|b)*abb"; /* regex used for matching */
  regex_t reg2 = "(a)*bab"

  // Matching the text against the regex1
  if (text =~ reg1) 
  {
    printf("text matches first regex(correct)\n");
  } else 
  {
    printf("text does not match first regex(incorrect)\n");
  }
  
  // Matching the text against the regex2
  if (text =~ reg2) 
  {
    printf("text matches second regex(incorrect)\n");
  } 
  else 
  {
    printf("Second text does not match second regex(correct)\n");
  }
  
  return 0;
}
