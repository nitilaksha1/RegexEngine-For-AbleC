 # Regex API Doc #<br />
The regular expression api's provided in this library are divided into two categories:
* Matching apis which check if a string matches a given regex
* Matched String apis which return the string that is matched by regex

* __Matching apis__:

These apis check if a given string matches a defined regular expression and returns a boolean result based on the success<br />
or failure of the match.
Following apis fit in this category:
  * __eBool match_full_string (struct DFA * dfa, char * str):__<br />
    Returns true if the entire string matches the regular expression.<br />
  *__eBool match_string_prefix (struct DFA * dfa, char * str):__<br />
    Returns true if the prefix of the given string matches the regular expression.<br />
