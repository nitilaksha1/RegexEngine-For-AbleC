/*This file shows the regular expression matching in case of full string matching against a regex*/

#include<stdio.h>

int main (int argc char ** argv) {
  
  const char *text1 = "abaabb";  /*text to match*/
  const char *text2 = "abcabc";  /*text to match*/
  const char *reg = "(a|b)*abb"; /*regex used for matching*/
  
  //Matching the text1 against the regex
  if (text1 =~ reg) {
    printf("First text matches (correct)\n");
  } else {
    printf("First text does not match (incorrect)\n");
  }
  
  //Matching the text2 against the regex
  if (text2 =~ reg) {
    printf("Second text matches (incorrect)\n");
  } else {
    printf("Second text does not match (correct)\n");
  }
  
  return 0;
}
