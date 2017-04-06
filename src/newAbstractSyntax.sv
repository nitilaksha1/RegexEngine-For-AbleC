-- Need a way to represent epsilon character in Silver
-- have decided to use '^' for time being

-- NFA is a type with three arributes which are stateCount, finalState and transTable
nonterminal NFA with stateCount, finalStates, transTable;

-- Transition is a type with three types which are fromState, toState and transChar
nonterminal Transition with fromState, toState, transChar;

synthesized attribute stateList :: [[Integer]];
synthesized attribute startState :: Integer;
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

	e.transTable = (createTrans(0, 1, '^') :: createTrans(l.stateCount, e.stateCount - 1, '^') :: createTrans(0, l.stateCount + 1, '^') :: createTrans(l.stateCount + r.stateCount, e.stateCount - 1, '^') :: e.transTable) ++ addToTransTable(r.transTable, l.stateCount + 1) ++ addToTransTable(l.transTable, 1); 

	--Set the final state
	e.finalStates = e.stateCount - 1;
	
	-- May be needed in future in case of design change
	-- e.finalStates = (e.stateCount - 1) :: e.finalStates;
}

-- Abstract production to handle Kleene (*) operator
abstract production KleeneOp
e::NFA ::= param::NFA
{
	-- Two extra states will get added
	e.stateCount = param.stateCount + 2;

	e.transTable = (createTrans(0, 1, '^') :: createTrans(param.stateCount, param.stateCount + 1, '^') :: createTrans(param.stateCount, 1, '^') :: createTrans(0, param.stateCount + 1, '^') :: e.transTable) ++ addToTransTable(param.transTable, 1);

	--Setting the final state
	e.finalStates = e.stateCount + 1;
	
	-- May be needed in future in case of design change
	-- e.finalStates = (e.stateCount + 1) :: e.finalStates;
}

-- Abstract production to concatenate two NFAs and produce the resultant NFA
abstract production ConcatOp
e :: NFA ::= l :: NFA r :: NFA
{
	-- The number of states in the resulting NFA will be the sum of vertices in the concatenated NFAs
	e.stateCount = l.stateCount + r.stateCount;
	
	e.transTable = (createTrans(l.stateCount - 1, l.stateCount, '^') :: e.transTable) ++ addToTransTable(l.transTable, 0) ++ addToTransTable(r.transTable, l.stateCount);
	
	--Setting the final state
	e.finalStates = (l.stateCount + r.stateCount - 1);
	
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
	e.finalStates = 1;
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

--Helper functions for NFA

function addToTransTable
[Transition] ::= transitions::[Transition] offset::Integer
{
	  return if null(transitions)
			then []
			else
				local attribute transition :: Transition = head(transitions);
				transition.fromstate = transition.fromstate + offset;
				transition.tostate = transtion. tostate + offset;
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

-- CLOSURE FUNCTION IMPLEMENTATION

-- The following functions implement epsilon-closure procedure:

-- Input to the main function: 
-- a) Transition Table
-- b) List of input states
-- c) Epsilon character
-- d) An empty list

-- Output:
-- a) A list of states that can be reached from the set of initial states by epsilon transitions

function epsClosure
[Integer] ::= nfa :: NFA inputStates :: [Integer]
{
	return epsClosureMultipleStates(nfa.transTable, inputStates, '^', nfa.transTable);	
}

function epsClosureMultipleStates
[Integer] ::= transitions :: [Transition] inputStates :: [Integer] inputChar :: RegexChar_t returnList :: [Integer]
{
	return if null(inputStates)
	then []
	else
		local attribute inputState :: Integer = head(inputStates);
		returnList = epsClosureOneState(transitions, inputState, '^', transitions);
		returnList = returnList ++ epsClosureMultipleStates(transitions, tail(inputStates), '^', []);
		removeDups(returnList, []);
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

-- MOVE FUNCTION

function move
[Integer] ::= state :: [Integer] input :: RegexChar_t nfa :: NFA
{
	return if null(state)
		then [];
		else
			removeDups((walkTransitions (nfa.transitions, head(state), input) ++ move (tail(state), input, nfa)), []);
}

--Some more helper functions

function walkTransitions
[Integer] ::= transitions::[Transition] state::Integer input::RegexChar_t
{
	return if null(transitions)
		then [];
		else
			local transition::Transition = head(transitions);

			if transition.transChar == input
				then transition.toState :: walkTransitions(tail(transitions), state, input);
			else
				walkTransitions(tail(transitions), state, input);
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


-- SUBSET CONSTRUCTION ALGORITHM IMPLEMENTATION

-- DFA is a type with arributes which are startState, list of finalStates, transTable, states

nonterminal DFA with startState, finalStates, transTable, states;

synthesized attribute startState :: Integer;
synthesized attribute states :: [[Integer]];
synthesized attribute finalStates :: [[Integer]];
synthesized attribute transTable :: [DFATransition];

nonterminal DFATransition with DFAFromState, DFAToState, transChar;

attribute DFAFromState :: [Integer];
attribute DFAToState :: [Integer];

function subsetConstruction
DFA ::= nfa::NFA
{
	local attribute dfa :: DFA;
	local attribute states :: [[Integer]];

	dfa.startState = epsClosure(nfa, [nfa.startState]);
	states = dfa.startState :: states;

	dfa = createDFA (nfa, dfa, states);
	-- Add code to generate unique IDs 
	return dfa;
}

function createDFA
DFA ::= nfa::NFA dfa::DFA states::[[Integer]]
{
	if null(states)
		then return dfa;
	else
		local attribute state :: [Integer] = head(states);
		
		if isStatePresent(nfa.finalStates, state)
			dfa.finalStates = state :: dfa.finalStates;

		dfa = createDFATransitions (state, nfa.inputs, dfa, nfa); 		

		dfa.states = removeCurrentState (state, states);

		return createDFA(nfa, dfa, dfa.states); 
}

function createDFATransitions 
DFA ::=	state :: [Integer] inputs :: [RegexChar_t] dfa::DFA nfa :: NFA
{
	if null(inputs)
		return dfa;
	else
		local attribute epsClosureList :: [Integer];
		
		epsClosureList = epsClosure (nfa, move(state, head(inputs), nfa));  

		if presentInDFAStates(epsClosureList, dfa.states)
			then dfa.states = epsclosurelist :: dfa.states;

		local dfaTransition :: DFATransition;

		dfaTransition.DFAFromState = state;
		dfaTransition.DFAToState = epsclosurelist;
		dfaTransition.transChar = head(inputs);

		dfa.transTable = dfaTransition :: dfa.transTable;

		return createDFATransitions(tail(inputs), dfa, state, nfa);		
}

function removeCurrentState
[[Integer]] ::= state::[Integer] states::[[Integer]]
{
	return if null(states)
		then [[]];

		else
			if head(states) !=  state
				then head(states) :: removeCurrentState(state, tail(states));
			else
				removeCurrentState(state, tail(states));
}
