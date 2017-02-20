
### Date: 02/07/2016
#### Attendees: Prof. Eric Van Wyk, Ambuj Nayan, Nitilaksha Halakatti

#### Discussion Points:
* High level approaches for the regex engine were discussed.
* Decided to go ahead with the following approach: Regex -> NFA -> DFA -> Match algorithm
* Regex be converted to NFA and DFA using Silver before passing the DFA to backend C code.
* Implementing a small regex engine in OCaml might be a good start before moving onto Silver.
* Examples of the implementation of new regex extension should be documented.
* Three different types of function calls were discussed:
  * bool match_1(str, DFA) // matches the entire string with the regex
  * match_2(str, DFA) // matches the string with part of the regex and returns the match information
  * match_3(str, DFA) // example of positional matching. 

#### Action items:
* Get the examples documented before the next meeting.

### Date: 02/14/2016
#### Attendees: Prof. Eric Van Wyk, Ambuj Nayan, Nitilaksha Halakatti

#### Discussion Points:
* Demonstration of the following two functions:
  * eBool match(struct DFA * dfa, char * str) : This function takes a DFA and string and returns true if the string conforms to the DFA  
  * eBool match_prefix (struct DFA * dfa, char * str) : The functions checks whether any prefix of the string conforms to the DFA
* Code clean was requried for both the functions.
* The DFA generation will ne handled by Silver and the need to document the generated C code for both the functions was discussed.
* The exitsing SQL extension should be studied for more ideas.

#### Action items:
* Document the generated C code for the disucssed functions.
