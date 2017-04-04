-- Need a way to represent epsilon character in Silver
-- have decided to use '^' for time being

-- NFA is a type with three arributes which are stateCount, list of finalStates and transTable
nonterminal NFA with stateCount, finalStates, transTable;

-- Transition is a type with three types which are fromState, toState and transChar
nonterminal Transition with fromState, toState, transChar;

synthesized attribute stateCount :: Integer;
synthesized attribute finalStates :: Integer;
synthesized attribute transTable :: [Transition];

attribute fromState :: Integer;
attribute toState :: Integer;
attribute transChar :: RegexChar_t;

-- Abstract production to handle Alternate (|) operator
abstract production AlternationOp
e::NFA ::= l::NFA r::NFA
{
	-- Resultant state count will be the sum of the state counts of the left NFA and the right NFA
	e.stateCount = l.stateCount + r.stateCount + 2;

	-- Create a new epsilon transition
	local attribute transition :: Transition;
	transition = createTrans(0, 1, '^');
	e.transTable = transition :: e.transTable;

	-- Add all the transitions of the left NFA to the resultant NFA
	e.transTable = e.transTable ++ addToTransTable(l.transTable, 1);

	-- Connect the intermediate final state of left NFA to resultant final state
	transition = createTrans(l.stateCount, e.stateCount - 1, '^');
	e.transTable = transition :: e.transTable;

	-- Connect the start state of the resultant NFA to the start state of right NFA
	transition = createTrans(0, l.stateCount + 1, '^');
	e.transTable = transition :: e.transTable;

	-- Add all the transitions of the right NFA to the resultant NFA
	e.transTable = e.transTable ++ addToTransTable(r.transTable, 1 + l.stateCount);

	-- Connect the final state of the right NFA to the resultant NFA
	transition = createTrans(l.stateCount + r.stateCount, e.stateCount - 1, '^');
	e.transTable = transition :: e.transTable;

	-- May be needed in future in case of design change
	-- e.finalStates = (e.stateCount - 1) :: e.finalStates;
}

-- Abstract production to handle Kleene (*) operator
abstract production KleeneOp
e::NFA ::= param::NFA
{
	-- Two extra states will get added
	e.stateCount = param.stateCount + 2;

	-- Add an epsilon transition to the start of the child NFA
	local attribute transition::Transition;
	transition = createTrans(0, 1, '^');
	e.transTable = transition :: e.transTable;

	-- Add all the transitions of the child NFA to the resultant NFA
	e.transTable = e.transTable ++ addToTransTable(param.transTable, 1);

	-- Add an epsilon transition to the end of the child NFA
	transition = createTrans(param.stateCount, param.stateCount + 1, '^');
	e.transTable = transition :: e.transTable;

	-- An an epsilon transition from the end of the child NFA to state 1
	transition = createTrans(param.stateCount, 1, '^');
	e.transTable = transition :: e.transTable;

	-- Add an epsilon transition from state 0 to the end state
	transition = createTrans(0, param.stateCount + 1, '^');
	e.transTable = transition :: e.transTable

	-- May be needed in future in case of design change
	-- e.finalStates = (e.stateCount + 1) :: e.finalStates;
}

-- Abstract production to concatenate two NFAs and produce the resultant NFA
abstract production ConcatOp
e :: NFA ::= l :: NFA r :: NFA
{
	-- The number of states in the resulting NFA will be the sum of vertices in the concatenated NFAs
	e.stateCount = l.stateCount + r.stateCount;
	
	-- Add all the transitions of the left NFA to the resultant NFA
	e.transTable = e.transTable ++ addToTransTable(l.transTable, 0);

	-- Add an epsilon transition from final state of left NFA to the start state of the right NFA
	local attribute transition :: Transition;
	transition = createTrans(l.stateCount - 1, l.stateCount, '^');
	e.transTable = transition :: e.TransTable

	-- Add all the transitions of the right NFA to the resultant NFA
	e.transTable = e.transTable ++ addToTransTable(r.transTable, l.stateCount);

	-- May be needed in future in case of design change
	-- e.finalStates = (l.stateCount + r.stateCount - 1) :: e.finalStates;
}

-- Abstract production to create a new NFA for a single unit
abstract production NewNfa
e :: NFA ::= param :: RegexChar_t
{
	e.stateCount = 2;
	local attribute transition :: Transition;
	transition = createTrans(0, 1, param);
	e.transTable = transition :: e.TransTable
}

-- Abstract production for epsilon transition
abstract production NewEpsilonTrans
e :: NFA ::=
{
	e.stateCount = 2;
	local attribute transition :: Transition;
	transition = createTrans(0, 1, '^');
	e.transTable = transition :: e.TransTable
}

function addToTransTable
[Transition] ::= transitions::[Transition] offset::Integer
{
	  return if null(transitions)
			then []
			else
				local attribute transition :: Transition = head(transitions);
				transition.fromState = transition.fromState + offset;
				transition.toState = transtion. toState + offset;
				transition :: addToTransTable(tail(transitions), offset);	
}

function createTrans
Transition ::= fromState :: Integer toState :: Integer transChar :: RegexChar_t
{
	local attribute transition :: Transition;
	transition.fromState = fromState;
	transition.toState = toState;
	transition.transChar = transChar;
	return transition; 
}

-- CODE FOR NFA to DFA CONVERSION:

-- The following four functions implement epsilon-closure procedure:

-- Input to the main function: 
-- a) Transition Table
-- b) List of input states
-- c) Epsilon character
-- d) An empty list

-- Output:
-- a) A list of states that can be reached from the set of initial states by epsilon transitions

function epsClosureMultipleStates
[Integer] ::= transitions :: [Transition] inputStates :: [Integer] inputChar :: RegexChar_t returnList :: [Integer]
{
	return if null(inputStates)
	then []
	else
		local attribute inputState :: Integer = head(inputStates);
		returnList = epsClosureOneState(transitions, inputState, '^', transitions);
		returnList = returnList ++ epsClosureMultipleStates(transitions, tail(inputStates), '^', []);
		removeDups(returnList);
}

function removeDups 
[Integer] ::= listWithDups :: [Integer] listWithOutDups :: [Integer]
{
	if null(listWithDups)
	then 
		return listWithOutDups;
	else 
		local attribute element :: Integer = head(listWithDups);
		if(isStatePresent(element, listWithOutDups))
		then
			return removeDups(tail(listWithDups), listWithOutDups); 
		else
			return removeDups(tail(listWithDups), element :: listWithOutDups);
}

function isStatePresent
Boolean ::= state::Integer statelist::[Integer]
{
        return if null(statelist)
                then false;
                else
                        if state == head(statelist)
                        then true;
                        else
                                isStatePresent(state, tail(statelist));
}

function epsClosureOneState
[Integer] ::= transitions :: [Transition] inputState :: Integer inputChar :: RegexChar_t returnList :: [Integer] staticTransitions :: [Transition]
{
	if null(transitions)
	then 
		return inputState :: returnList
	else
		local attribute transition :: Transition = head(transitions);
		if inputState == transition.fromState && inputChar == transition.transChar
		then
			local attribute dynamicTransTable :: [Transition] = staticTransitions;
			returnList = epsClosureOneState(dynamicTransTable, transition.toState, '^', returnList, staticTransitions);
			return epsClosureOneState(tail(transitions), inputState, '^', returnList, staticTransitions);
		else
			return epsClosureOneState(tail(transitions), inputState, '^', returnList, staticTransitions);
}

-- SUBSET CONSTRUCTION ALGORITHM IMPLEMENTATION

-- DFA is a type with arributes which are dfaStartState, list of dfaFinalStates, dfaTransTable, dfaStates, mapper, unmarkedStateList

nonterminal DFA with dfaStartState, dfaFinalStates, dfaTransTable, dfaStates, mapper, unmarkedStateList;

synthesized attribute dfaStartState :: Integer;
synthesized attribute dfaStates :: [Integer];
synthesized attribute dfaFinalStates :: [Integer];
synthesized attribute mapper::[Pair<Integer [Integer]>];
synthesized attribute dfaTransTable :: [Transition];
synthesized attribute unmarkedStateList :: [Integer];

function createDFA
DFA ::= nfa :: NFA
{

	local attribute dfa :: DFA;

	local attribute startState :: [Integer];
	startState = epsClosureOneState(nfa.transTable, 0, '^', [], nfa.transTable);

	-- generate a unique number for the set of startStates
	local attribute uniqueState :: Integer = genInt();

	-- Need a mapper between uniqueState and a set of states
	dfa.mapper = [ pair(uniqueState, startState) ];

	-- Add the unique DFA state to the list of DFA states
	dfa.dfaStates = uniqueState :: dfa.dfaStates;

	- Add the unique DFA state to the list of unmarked states
	dfa.unmarkedStateList = uniqueState :: dfa.unmarkedStateList;

	-- Set this as the start state of the DFA
	dfa.dfaStartState = uniqueState;

	dfa = processUnmarkedList(nfa, dfa);
	return dfa;
}

function processUnmarkedList
DFA ::= nfa :: NFA dfa :: DFA
{
	if null(dfa.unmarkedStateList)
	then 
		return dfa;
	else
		local attribute markedState :: Integer = head(dfa.unmarkedStateList);

		-- get the list of states corresponding to markedState from mapper
		local attribute markedStateList :: [Integer];
		markedStateList = lookup(markedState, dfa.mapper);

		-- function to check if markedStateList contains a final state
		if finalStateCheck(nfa.finalStates, markedStateList)
		then
			dfa.dfaFinalStates = markedState :: dfa.dfaFinalStates;

		dfa = processInputSymbol(nfa, dfa, markedState, nfa.inputSymbolsList);
		dfa.unmarkedStateList = tail(dfa.unmarkedStateList);
		return processUnmarkedList(nfa, dfa);
}

function processInputSymbol
DFA ::= nfa :: NFA dfa :: DFA markedState :: Integer inputSymbolsList :: [RegexChar_t]
{
	if null(inputSymbolsList)
	then
		return dfa;
	else
		local attribute transChar :: RegexChar_t = head(inputSymbolsList);
		local attribute markedStateList :: [Integer];
		markedStateList = lookup(markedState, dfa.mapper);

		local attribute moveStates :: [Integer];
		moveStates = move(markedStateList, transChar);

		listOfStatesU = epsClosureMultipleStates(nfa.transTable, moveStates, '^', []);

		local attribute checkState :: Integer;
		checkState = tailLookup(listOfStatesU, dfa.mapper);
		local attribute uniqueState :: Integer;
		uniqueState = checkState;

		if(checkState == -1)
		then
			uniqueState = genInt();  
			dfa.mapper = pair(uniqueState, listOfStatesU) :: dfa.mapper;
			dfa.dfaStates = uniqueState :: dfa.dfaStates;
			dfa.unmarkedStateList = uniqueState :: dfa.unmarkedStateList;

		local attribute transition :: Transition;
		transition = createTrans(markedState, uniqueState, transChar);
		dfa.transTable = transition :: dfa.transTable;
		return processInputSymbol(nfa, dfa, markedState, tail(inputSymbolsList));
} 

function tailLookup
[Integer] ::= listOfStatesU :: Integer mapper :: [ Pair<Integer [Integer]> ]
{
  return if null(mapper)
         	then -1;
         else
			 if listOfStatesU == head(mapper).snd
		         then head(mapper).fst
			 else lookup(listOfStatesU, tail(mapper));
}

function finalStateCheck
boolean ::= nfaFinalState :: Integer markedStateList :: [Integer]
{
	if null(markedStateList)
	then
		return false;
	else
		if(nfaFinalState == head(markedStateList))
		then
			return true;
		else
			return finalStateCheck(nfaFinalState, tail(markedStateList));
}

function lookup
[Integer] ::= uniqueState :: Integer mapper :: [ Pair<Integer [Integer]> ]
{
  return if null(mapper)
         	then []
         else
			 if uniqueState == head(mapper).fst
		         then head(mapper).snd
			 else lookup(uniqueState, tail(mapper));
}


-- Code from here till the end of the page has been commented

{--

function finalStateConnectionForConcat
[Transition] ::= finalStates::[Integer] toState::Integer transChar::RegexChar_t 
{
	return if null(finalStates)
		then []
		else
			local attribute transition :: Transition;
			transition.fromState = head(finalstates);
			transition.toState = tostate;
			transition.transChar = transchar;
			transition :: finalStateConnectionForConcat(tail(finalstates), tostate, transchar);		
}


function setFinalStatesForConcat
[Integer] ::= finalstates::[Integer] offset::Integer
{
	return if null(finalstates)
		then []
		else
			(head(finalstates) + offset) :: setFinalStatesForConcat(tail(finalstates), offset);
}

--}
