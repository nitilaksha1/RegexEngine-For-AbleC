grammar edu:umn:cs:melt:exts:ableC:regex:src:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax;
imports silver:langutil;
imports silver:langutil:pp;
imports edu:umn:cs:melt:exts:ableC:regex:src:concretesyntax;

-- Need a way to represent epsilon character in Silver
-- have decided to use '^' for time being

-- nonterminal ROOT with pp, regex;
nonterminal ROOT with pp, regex;

-- REGEX is a type with NFA and pp
nonterminal REGEX with pp, nfa;

-- NFA is a type with three arributes which are stateCount, finalState and transTable
-- nonterminal NFA with stateCount, finalStates, transTable, prevState, dfa;
nonterminal NFA with stateCount, finalStates, transTable, prevState;

-- Transition is a type with three types which are fromState, toState and transChar
nonterminal Transition with fromState, toState, transChar;

synthesized attribute nfa :: NFA;
synthesized attribute regex :: REGEX;
inherited attribute prevState :: Integer;
synthesized attribute stateList :: [[Integer]];
synthesized attribute startState :: Integer;
synthesized attribute stateCount :: Integer;
synthesized attribute finalStates :: Integer;
synthesized attribute transTable :: [Transition];

synthesized attribute fromState :: Integer;
synthesized attribute toState :: Integer;
synthesized attribute transChar :: String;

synthesized attribute pp :: String;
--synthesized attribute dfa:: DFA;

abstract production rootREGEX
r::ROOT ::= x::REGEX
{
  r.pp = x.pp ;
}

-- Abstract production to handle Alternate (|) operator
abstract production AlternationOp
e::REGEX ::= l::REGEX r::REGEX
{
	e.nfa = AlternationOpFun(l.nfa, r.nfa); 
	e.pp = populatePP(e.nfa.transTable);
}

-- Function handle Alternate (|) operator
function AlternationOpFun
NFA ::= l::NFA r::NFA
{
	local attribute transList :: [Transition] = (createTrans(0, 1, "^") :: createTrans(l.stateCount, l.stateCount + r.stateCount + 1, "^") :: createTrans(0, l.stateCount + 1, "^") :: createTrans(l.stateCount + r.stateCount, l.stateCount + r.stateCount + 1, "^") :: []) ++ addToTransTable(r.transTable, l.stateCount + 1) ++ addToTransTable(l.transTable, 1);

	local attribute e :: NFA = initNFA(l.stateCount + r.stateCount + 2, transList, l.stateCount + r.stateCount + 1);
	
	return e;
}

-- Abstract production to handle Kleene (*) operator
abstract production KleeneOp
e::REGEX ::= param::REGEX
{
	e.nfa = KleeneOpFun(param.nfa);
	e.pp = populatePP(e.nfa.transTable);
}

-- Function to handle Kleene (*) operator
function KleeneOpFun
NFA ::= param::NFA
{
	local attribute transList :: [Transition] = (createTrans(0, 1, "^") :: createTrans(param.stateCount, param.stateCount + 1, "^") :: createTrans(param.stateCount, 1, "^") :: createTrans(0, param.stateCount + 1, "^") :: []) ++ addToTransTable(param.transTable, 1);

	local attribute e :: NFA = initNFA(param.stateCount + 2, transList, param.stateCount + 3);

	return e;
}

-- Abstract production to concatenate two NFAs and produce the resultant NFA
abstract production ConcatOp
e :: REGEX ::= l :: REGEX r :: REGEX
{
	e.nfa = ConcatOpFun(l.nfa, r.nfa);
	e.pp = populatePP(e.nfa.transTable);
}

-- Function to concatenate two NFAs and produce the resultant NFA
function ConcatOpFun
NFA ::= l :: NFA r :: NFA
{
	local attribute transList :: [Transition] = (createTrans(l.stateCount - 1, l.stateCount, "^") :: []) ++ addToTransTable(l.transTable, 0) ++ addToTransTable(r.transTable, l.stateCount);

	local attribute e :: NFA = initNFA(l.stateCount + r.stateCount, transList, l.stateCount + r.stateCount - 1);

	return e;
}

-- Abstract production to create a new NFA for a single unit
abstract production NewNfa
e :: REGEX ::= param :: String
{
	e.nfa = NewNfaFun(param);
	e.pp = populatePP(e.nfa.transTable);
}

-- Function to create a new NFA for a single unit
function NewNfaFun
NFA ::= param :: String
{
	local attribute transition :: Transition;
	transition = createTrans(0, 1, param);
	local attribute e :: NFA = initNFA(2, [transition], 1);
	return e;
}

-- Helper functions for NFA

function addToTransTable
[Transition] ::= transitions::[Transition] offset::Integer
{
	return if null(transitions)
	then 
		[]
	else
		returnTrans(head(transitions), offset) :: addToTransTable(tail(transitions), offset);	
}

abstract production returnTrans
transition :: Transition ::= trans :: Transition offset :: Integer
{
	transition.fromState = trans.fromState + offset;
	transition.toState = trans.toState + offset;
	transition.transChar = trans.transChar;
}

abstract production initNFA
r :: NFA ::= stateCount :: Integer transTable :: [Transition] finalStates :: Integer 
{
	r.stateCount = stateCount;
	r.transTable = transTable;
	r.finalStates = finalStates;
}

abstract production initTrans
t :: Transition ::= fromState :: Integer toState :: Integer transChar :: String
{
	t.fromState = fromState;
	t.toState = toState;
	t.transChar = transChar;
}

function createTrans
Transition ::= fromState :: Integer toState :: Integer transChar :: String
{
	local attribute transition :: Transition = initTrans(fromState, toState, transChar);
	
	return transition; 	
}

function populatePP
String ::= transitions::[Transition]
{
	return if null(transitions)
		then ""
		else
			-- local attribute transition::Transition = head(transitions);
			"(" ++ toString(head(transitions).fromState) ++ "," ++ toString(head(transitions).toState) ++ "," ++ head(transitions).transChar ++ ")" ++ populatePP(tail(transitions));

}

{-

-- Uncomment the code
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
		removeDups(epsClosureOneState(transitions, head(inputStates), '^', transitions) ++ epsClosureMultipleStates(transitions, tail(inputStates), '^', []), []);
}

function epsClosureOneState
[Integer] ::= transitions :: [Transition] inputState :: Integer inputChar :: RegexChar_t returnList :: [Integer] staticTransitions :: [Transition]
{
	return if null(transitions)
	then 
		inputState :: returnList
	else
		if inputState == head(transitions).fromState && inputChar == head(transitions).transChar
		then
			epsClosureOneState(tail(transitions), inputState, '^', epsClosureOneState(staticTransitions, head(transitions).toState, '^', returnList, staticTransitions), staticTransitions)
		else
			epsClosureOneState(tail(transitions), inputState, '^', returnList, staticTransitions);
}

-- MOVE FUNCTION

function move
[Integer] ::= state :: [Integer] input :: RegexChar_t nfa :: NFA
{
	return if null(state)
		then []
		else
			removeDups((walkTransitions (nfa.transitions, head(state), input) ++ move (tail(state), input, nfa)), []);
}

--Some more helper functions

function walkTransitions
[Integer] ::= transitions::[Transition] state::Integer input::RegexChar_t
{
	return if null(transitions)
		then []
		else
			if head(transitions).transChar == input
				then head(transitions).toState :: walkTransitions(tail(transitions), state, input)
			else
				walkTransitions(tail(transitions), state, input);
}

function removeDups 
[Integer] ::= listWithDups :: [Integer] listWithOutDups :: [Integer]
{
	return if null(listWithDups)
	then 
		listWithOutDups
	else 
		if(isStatePresent(head(listWithDups), listWithOutDups))
		then
			removeDups(tail(listWithDups), listWithOutDups)
		else
			removeDups(tail(listWithDups), head(listWithDups) :: listWithOutDups);
}

function isStatePresent
Boolean ::= state::Integer statelist::[Integer]
{
	return if null(statelist)
		then false
		else
			if state == head(statelist) 
			then true
			else
				isStatePresent(state, tail(statelist));
}


-- SUBSET CONSTRUCTION ALGORITHM IMPLEMENTATION

-- DFA is a type with arributes which are startState, list of finalStates, transTable, states

nonterminal DFA with startState, finalStates, transTable, states, c;

synthesized attribute startState :: Integer;
synthesized attribute states :: [[Integer]];
synthesized attribute finalStates :: [[Integer]];
synthesized attribute transTable :: [DFATransition];
synthesized attribute c :: String;

nonterminal DFATransition with DFAFromState, DFAToState, transChar;

synthesized attribute DFAFromState :: [Integer];
synthesized attribute DFAToState :: [Integer];

abstract production subsetConstruction
d :: DFA ::= nfa::NFA
{
	d.startState = epsClosure(nfa, [nfa.startState]);
	d = createDFA (nfa, d, d.startState);
	-- Add code to generate unique IDs 
	-- Add code to add final states
	--d.finalStates = populateFinalStates(d.states, nfa.finalStates);
}

function createDFA
DFA ::= nfa::NFA dfa::DFA states::[[Integer]]
{
	return if null(states)
	then 
		dfa
	else
		if isStatePresent(nfa.finalStates, head(states))
		then 
			createDFA(nfa, createDFATransitions (head(states), nfa.inputs, dfa, nfa), removeCurrentState (head(states), states)) 
		else
			createDFA(nfa, createDFATransitions (head(states), nfa.inputs, dfa, nfa), removeCurrentState (head(states), states)); 
}

function createDFATransitions 
DFA ::=	state :: [Integer] inputs :: [RegexChar_t] dfa::DFA nfa :: NFA
{
	return if null(inputs)
	then
		dfa
	else
		createDFATransitions(tail(inputs), helperProduct(state, inputs, dfa, nfa), state, nfa);		
}

abstract production helperProduct
d :: DFA ::=state :: [Integer] inputs :: [RegexChar_t] dfa::DFA nfa :: NFA
{
	local attribute epsClosureList :: [Integer];
	epsClosureList = epsClosure (nfa, move(state, head(inputs), nfa));  

	-- if presentInDFAStates(epsClosureList, dfa.states)
	-- then 
		dfa.states = epsclosurelist :: dfa.states;

	local attribute dfaTransition :: DFATransition;
	dfaTransition.DFAFromState = state;
	dfaTransition.DFAToState = epsclosurelist;
	dfaTransition.transChar = head(inputs);
	dfa.transTable = dfaTransition :: dfa.transTable;
	d=dfa;		
}

function removeCurrentState
[[Integer]] ::= state::[Integer] states::[[Integer]]
{
	return if null(states)
	then [[]]
	else
		if head(states) !=  state
		then 
			head(states) :: removeCurrentState(state, tail(states))
		else
			removeCurrentState(state, tail(states));
}

-}