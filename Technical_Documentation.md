# Regex Engine for ableC

### Team Memembers:
* Ambuj Nayan
* Nitilaksha Halakatti

### Advisor:
* Professor Eric Van Wyk

### Objective:

The purpose of this extension is the development of a regular expression engine for ableC. There are several approaches one could take to build regular expression engine. We have chosen the following approach:

* Generate a Nondeterministic Finite Automaton from the input regular expression
* Convert the Nondeterministic Finite Automaton to a Deterministic Finite Automaton
* Simulate the Deterministic Finite Automaton against the given string

### Execution steps:
* Clone the repository
* Build the code base by running the build script:  
```./build```
* Examples are located in the folder: `edu.umn.cs.melt.exts.ableC.regex/examples`  
* Run a sample ableC code by executing the following command:  `java -jar ableC edu.umn.cs.melt.exts.ableC.regex/examples/mainExample.xc`
* This will prouduce: `mainExample.c`
* Execute the produced C code
* Libraries to be included in the .xc program are:
```#include "dfa.h"``` and ```#include "regex.h"```

#### Concrete syntax:
```RE ::= C```  
```RE ::= RE|C```    
```C ::= B```  
```C ::= C B```   
```B ::= Sim```  
```B ::= B *```  
```B ::= (RE)```  
```Sim ::= REGEX_CHAR```  
```REGEX_CHAR ::= a|b|c ...```

#### Conversion of regular expression to NFA using Thompson's construction

Thompson's construction is a recursive algorithm that works by splitting the regular expression into its constituent subexpressions. These subexpressions are then used to construct the NFA.

Following four expressions are handled by our implementation of Thompson's construction:
* Expression with a single input unit  
```abstract production NewNfa```

* Concatenation expression  
```abstract production ConcatOp```
* Kleene star expression  
```abstract production KleeneOp```

* Alternation (or union) expression  
```abstract production AlternationOp```

The NFA returned by our implementation of Thompson's construction is a non terminal with the following attributes:
* Count of states
* List of final states
* Transition table
* List of input symbols
* DFA corresponding to this NFA

```nonterminal NFA with stateCount, finalStates, transTable, inputs, dfa;```

#### Conversion of NFA to DFA using Subset construction

We use Subset construction algorithm to get a DFA from NFA. The steps involved are as follows:

1. epsilon-closure of the start state of the NFA yields the start state of the DFA  
```function epsClosureDFAFun```  
```DFA ::= nfa :: NFA nfaStartState :: [Integer]```
2. Repeat the following for the new DFA state:  
   For each input symbol:
   * Get a new set of states by applying move function to the newly created state and the input symbol.  
   ```function move```  
   ```[Integer] ::= state :: [Integer] input :: String nfa :: NFA```
   * epsilon-closure of the set of states obtained in the previous step will return a new set of states.  
   ```local attribute epsClosureList :: [Integer];```  
   ```epsClosureList = epsClosure (nfa, move(state, head(inputs), nfa));```
   * The set of states returned by epsilon-closure will be a single state in the DFA
3. For each new state in DFA, apply step 2 till no new states are produced.
4. The final states of the DFA are those states which have any of the final states of the NFA.

The DFA returned by our implementation of Thompson's construction is a non terminal with the following attributes:
* Start state
* List of final states
* Transition table
* List of states
* Number of states

```nonterminal DFA with dfaStartState, dfaFinalStates, dfaTransTable, dfaStates, dfaMapper, c, dfaSize;```

#### Regex API Doc (regex.h)
  * ```int test_full_string (struct DFA * dfa, char * str)```: <br />
    Returns true if the prefix of the given string matches the regular expression.<br />
  * For additional API documentation, check ```Regex API Doc.md```
