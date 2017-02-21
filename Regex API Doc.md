  #__Regex API Doc__#<br />
The regular expression api's provided in this library are divided into two categories:
* Regex test functions which check if a string matches a given regex
* Regex match functions which return the string that is matched by regex<br />

* __Regex test apis:__<br />
These functions check if a given string matches a defined regular expression and returns a boolean result based on the success<br />
or failure of the match.<br />
Following functions fit in this category:<br />
  * __eBool test_full_string (struct DFA * dfa, char * str):__ <br />
    Returns true if the prefix of the given string matches the regular expression.<br />
  * __eBool test_string_prefix (struct DFA * dfa, char * str):__<br />
    Returns true if the entire string matches the regular expression.<br /><br />
* __Regex Match Functions:__<br />
These functions return the matched string for a given regular expression if a match exists.<br />
Following functions fall in this category:<br /><br />
  * __struct matchInfo match_prefix (struct DFA * dfa, char * str):__ <br />
    Returns the longest prefix that matches the given regular expression. The matchInfo struct contains the first index of the<br />match in the string and the number of characters in the match.
  * __struct matchInfo match_anywhere(struct DFA * dfa, char * str):__ <br />
    Returns the first matched substring that matches the regular expression. The matchInfo struct contains the index of the<br /> first character matched and the number of characters matched. It also returns the index of the first character <br /> following the matched substring so that the rest of the string can be queried for more matched using the returned<br /> truncated string. <br />
