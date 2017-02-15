/*This file demonstrates the use of "=*" operator which checks if the regular expression is matched at the beginning of the string*/

#include<stdio.h>

int main (int argc, char ** argv) {
  
  const char *text1 = "abaabbababc";  /*good case to match*/
  const char *text2 = "ababcabababb"; /*bad case to match*/

  regex_t reg = "(a|b)*abb"; /*regex used for matching*/

  //Matching the text1 against the regex
  if (text1 =* reg) {
    printf("text1 matches regex(correct)\n");
  } else {
    printf("text1 does not match regex(incorrect)\n");
  }
  
  //Matching the text2 against the regex
  if (text2 =* reg) {
    printf("text2 matches regex(incorrect)\n");
  } else {
    printf("text2 does not match regex(correct)\n");
  }
  
  return 0;
}
