-- Current Status:
-- 1) REGEX to NFA conversion works
-- 2) NFA to DFA conversion works
-- 3) Generate C code for the DFA

-- TO DO:
-- 1) Integration with ableC

grammar edu:umn:cs:melt:exts:ableC:regex:src:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax;
imports silver:langutil;
imports silver:langutil:pp;

-- nonterminal ROOT with pp, regex;
nonterminal ROOT with pp, regex;

-- REGEX is a type with NFA and pp
nonterminal REGEX with pp, nfa;

-- NFA is a type with three arributes which are stateCount, finalState and transTable
nonterminal NFA with stateCount, finalStates, transTable, inputs, dfa;

-- Transition is a type with three types which are fromState, toState and transChar
nonterminal Transition with fromState, toState, transChar;

synthesized attribute nfa :: NFA;
synthesized attribute regex :: REGEX;
synthesized attribute stateList :: [[Integer]];
synthesized attribute startState :: Integer;
synthesized attribute stateCount :: Integer;
synthesized attribute inputs :: [String];
synthesized attribute finalStates :: Integer;
synthesized attribute transTable :: [Transition];
synthesized attribute fromState :: Integer;
synthesized attribute toState :: Integer;
synthesized attribute transChar :: String;
synthesized attribute pp :: String;
synthesized attribute dfa:: DFA;

-- Integration with ableC start

abstract production dummyProd
top :: Expr ::=
{
   forwards to txtExpr("Hello World", location=top.location);
   
   --forwards to injectGlobalDeclsExpr(consDecl(txtDecl("int a"), nilDecl()), txtExpr("5", --location=top.location), location=top.location);
}

-- Integration with ableC end

abstract production rootREGEX
r :: ROOT ::= x :: REGEX
{
   r.pp = (getDFAFromNFA(x.nfa)).c;
}

-- Function to invoke subset construction algorithm
function getDFAFromNFA
DFA ::= nfa :: NFA
{
	local attribute nfa1 :: NFA = subsetConstruction(nfa);
	return nfa1.dfa;
}

-- Abstract production to handle Alternate (|) operator
abstract production AlternationOp
e :: REGEX ::= l :: REGEX r :: REGEX
{
	e.nfa = AlternationOpFun(l.nfa, r.nfa); 
	e.pp = populatePP(e.nfa.transTable);
}

-- Function handle Alternate (|) operator
function AlternationOpFun
NFA ::= l :: NFA r :: NFA
{
	local attribute transList :: [Transition] = (createTrans(0, 1, "^") :: createTrans(l.stateCount, l.stateCount + r.stateCount + 1, "^") :: createTrans(0, l.stateCount + 1, "^") :: createTrans(l.stateCount + r.stateCount, l.stateCount + r.stateCount + 1, "^") :: []) ++ addToTransTable(r.transTable, l.stateCount + 1) ++ addToTransTable(l.transTable, 1);

	local attribute e :: NFA = initNFA(l.stateCount + r.stateCount + 2, transList, l.stateCount + r.stateCount + 1, l.inputs ++ r.inputs);
	
	return e;
}

-- Abstract production to handle Kleene (*) operator
abstract production KleeneOp
e :: REGEX ::= param :: REGEX
{
	e.nfa = KleeneOpFun(param.nfa);
	e.pp = populatePP(e.nfa.transTable);
}

-- Function to handle Kleene (*) operator
function KleeneOpFun
NFA ::= param :: NFA
{
	local attribute transList :: [Transition] = (createTrans(0, 1, "^") :: createTrans(param.stateCount, param.stateCount + 1, "^") :: createTrans(param.stateCount, 1, "^") :: createTrans(0, param.stateCount + 1, "^") :: []) ++ addToTransTable(param.transTable, 1);

	local attribute e :: NFA = initNFA(param.stateCount + 2, transList, param.stateCount + 3, param.inputs);

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

	local attribute e :: NFA = initNFA(l.stateCount + r.stateCount, transList, l.stateCount + r.stateCount - 1, l.inputs ++ r.inputs);

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
	local attribute e :: NFA = initNFA(2, [transition], 1, [param]);
	return e;
}

-- HELPER FUNCTIONS/PRODUCTIONS FOR NFA CONSTRUCTION

function addToTransTable
[Transition] ::= transitions :: [Transition] offset :: Integer
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
r :: NFA ::= stateCount :: Integer transTable :: [Transition] finalStates :: Integer input :: [String] 
{
	r.stateCount = stateCount;
	r.transTable = transTable;
	r.finalStates = finalStates;
	r.inputs = removeStringDuplicate(input, []);
}

function createTrans
Transition ::= fromState :: Integer toState :: Integer transChar :: String
{
	local attribute transition :: Transition = initTrans(fromState, toState, transChar);
	return transition; 	
}

abstract production initTrans
t :: Transition ::= fromState :: Integer toState :: Integer transChar :: String
{
	t.fromState = fromState;
	t.toState = toState;
	t.transChar = transChar;
}

function populatePP
String ::= transitions :: [Transition]
{
	return if null(transitions)
		then 
			""
		else
			"(" ++ toString(head(transitions).fromState) ++ "," ++ toString(head(transitions).toState) ++ "," ++ head(transitions).transChar ++ ")" ++ populatePP(tail(transitions));
}

-- NFA CODE ENDS HERE

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

-- CODE FOR NFA to DFA CONVERSION:

-- SUBSET CONSTRUCTION ALGORITHM IMPLEMENTATION

-- DFA is a type with arributes which are startState, list of finalStates, transTable, states
nonterminal DFA with dfaStartState, dfaFinalStates, dfaTransTable, dfaStates, dfaMapper, c, dfaSize;

synthesized attribute dfaStartState :: [Integer];
synthesized attribute dfaStates :: [[Integer]];
synthesized attribute dfaFinalStates :: [[Integer]];
synthesized attribute dfaTransTable :: [DFATransition];
synthesized attribute c :: String;
synthesized attribute DFAFromState :: [Integer];
synthesized attribute DFAToState :: [Integer];
synthesized attribute dfaMapper :: [Pair<[Integer] Integer>];
synthesized attribute dfaSize :: Integer;

nonterminal DFATransition with DFAFromState, DFAToState, transChar;

-- Starting point of subset construction algorithm
abstract production subsetConstruction
n :: NFA ::= nfa :: NFA
{
	n.dfa = populateCCode
			(
				populateMapper
				(
					createDFA (nfa, epsClosureDFAFun(nfa, [0]), [epsClosure(nfa, [0])], [])
				)
			);
}

-- This function populates the mapper between list of states and unique ID generated for each state
function populateMapper
DFA ::= dfa :: DFA
{
	return helperPopulateMapper(dfa);
}

abstract production helperPopulateMapper
semiFinalDFA :: DFA ::= dfa :: DFA
{
	semiFinalDFA.dfaStartState = dfa.dfaStartState;
	semiFinalDFA.dfaFinalStates = dfa.dfaFinalStates;
	semiFinalDFA.dfaTransTable = dfa.dfaTransTable;
	semiFinalDFA.dfaStates = dfa.dfaStates;	
	semiFinalDFA.c = dfa.c;
	semiFinalDFA.dfaSize = getStateCount(dfa.dfaStates, 0);
	semiFinalDFA.dfaMapper = mapperFunc(dfa.dfaStates, 0);
}

-- This function creates the C code
function populateCCode
DFA ::= dfa :: DFA
{
	return helperPopulateCCode(dfa);
}

abstract production helperPopulateCCode
finalDFA :: DFA ::= dfa :: DFA
{
	finalDFA.dfaStartState = dfa.dfaStartState;
	finalDFA.dfaFinalStates = dfa.dfaFinalStates;
	finalDFA.dfaTransTable = dfa.dfaTransTable;
	finalDFA.dfaStates = dfa.dfaStates;
	finalDFA.dfaMapper = dfa.dfaMapper;
	finalDFA.dfaSize = dfa.dfaSize;

	finalDFA.c =
	"#include <stdio.h>\n" ++
	"#include \"dfa.h\"\n" ++
	"#include \"regex.h\"\n\n" ++

	"extern void init_DFA (struct DFA *, state, int);\n" ++
	"extern void add_trans (struct DFA *, state, state, input);\n" ++
	"extern void set_final_state (struct DFA *, state);\n" ++
	"extern eBool match (struct DFA *, char *);\n" ++
	"extern void release_DFA (struct DFA *);\n\n" ++

	"int main(int argc, char ** argv)\n" ++
	"{\n\n" ++
	"\tstruct DFA dfa1;\n" ++
	"\tinit_DFA (&dfa1, " ++ toString(lookup(sortBy(lteSilver, dfa.dfaStartState), dfa.dfaMapper)) ++ ", " ++ toString(dfa.dfaSize) ++ ");\n" ++
	getFinalStatesCCode(dfa.dfaFinalStates, dfa.dfaMapper) ++
	getTransitionsCCode(dfa.dfaTransTable, dfa.dfaMapper) ++
	"\n\tchar text[50];\n" ++
	"\tprintf(\"Enter a string: \");\n" ++
	"\tgets(text);\n\n" ++
  	"\tif (test_full_string (&dfa1, text) == TRUE)\n" ++ 
  	"\t{\n" ++
    "\t\tprintf(\"Text matches regex\");\n" ++
    "\t}\n" ++ 
    "\telse\n" ++ 
    "\t{\n" ++
    "\t\tprintf(\"Text does not match regex\");\n" ++
    "\t}\n\n" ++
    "\trelease_DFA (&dfa1);\n" ++
    "\treturn 0;\n" ++
    "}\n";
}

function epsClosureDFAFun
DFA ::= nfa :: NFA nfaStartState :: [Integer]
{
	return epsClosureDFA(epsClosure(nfa, [0]));
}

abstract production epsClosureDFA
d :: DFA ::= epsClosureRes :: [Integer]
{
	d.dfaStartState = epsClosureRes;
	d.dfaStates = [sortBy(lteSilver, d.dfaStartState)];
	d.dfaTransTable = [];
	d.dfaFinalStates = [];
	d.dfaMapper = [];
	d.c = "";
	d.dfaSize = 0;
}

-- CLOSURE FUNCTION IMPLEMENTATION
-- The following functions implement epsilon-closure procedure:

-- Input to the main function: 
-- a) Transition Table b) List of input states c) Epsilon character d) An empty list

-- Output:
-- a) A list of states that can be reached from the set of initial states by epsilon transitions

function epsClosure
[Integer] ::= nfa :: NFA inputStates :: [Integer]
{
	return epsClosureMultipleStates(nfa.transTable, inputStates, "^");	
}

function epsClosureMultipleStates
[Integer] ::= transitions :: [Transition] inputStates :: [Integer] inputChar :: String
{
	return if null(inputStates)
	then []
	else
		removeDups(epsClosureOneState(transitions, head(inputStates), "^", [], transitions) ++ epsClosureMultipleStates(transitions, tail(inputStates), "^"), []);
}

function epsClosureOneState
[Integer] ::= transitions :: [Transition] inputState :: Integer inputChar :: String returnList :: [Integer] staticTransitions :: [Transition]
{
	return if null(transitions)
	then 
		inputState :: returnList
	else
		if inputState == head(transitions).fromState && inputChar == head(transitions).transChar
		then
			epsClosureOneState(tail(transitions), inputState, "^", epsClosureOneState(staticTransitions, head(transitions).toState, "^", returnList, staticTransitions), staticTransitions)
		else
			epsClosureOneState(tail(transitions), inputState, "^", returnList, staticTransitions);
}

-- This function creates the DFA
function createDFA
DFA ::= nfa :: NFA dfa :: DFA states :: [[Integer]] tempStates :: [[Integer]]
{
	return if null(states)
	then 
		dfa
	else
		if isStatePresent(nfa.finalStates, head(states))
		then 
			createDFA(nfa, createDFATransitions (head(states), nfa.inputs, AddFinalStateToDFA(head(states), dfa), UpdateDFAForNfa(nfa, AddFinalStateToDFA(head(states), dfa))), removeCurrentState (head(states)::tempStates, createDFATransitions (head(states), nfa.inputs, dfa, nfa).dfaStates), head(states) :: tempStates)  
		else
			createDFA(nfa, createDFATransitions (head(states), nfa.inputs, dfa, nfa), removeCurrentState (head(states) :: tempStates, createDFATransitions (head(states), nfa.inputs, dfa, nfa).dfaStates), head(states) :: tempStates); 
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

function createDFATransitions 
DFA ::=	state :: [Integer] inputs :: [String] dfa :: DFA nfa :: NFA
{
	return if null(inputs)
	then
		dfa
	else
		createDFATransitions(state, tail(inputs), helperProduct(state, inputs, dfa, nfa), nfa);		
}

abstract production helperProduct
d :: DFA ::= state :: [Integer] inputs :: [String] dfa :: DFA nfa :: NFA
{
	local attribute epsClosureList :: [Integer];
	epsClosureList = epsClosure (nfa, move(state, head(inputs), nfa));  

	d.dfaStates = helperDFAStates(epsClosureList, dfa.dfaStates);
	d.dfaStartState = dfa.dfaStartState;
	d.dfaFinalStates = dfa.dfaFinalStates;
	d.c = dfa.c;
	d.dfaMapper = dfa.dfaMapper;
	d.dfaSize = dfa.dfaSize;
	d.dfaTransTable = getUpdatedTransTable(state, epsClosureList, head(inputs), dfa.dfaTransTable);
}

function helperDFAStates
[[Integer]] ::= list :: [Integer] states :: [[Integer]]
{
	return if null(list)
	then
		states
	else
		removeDupDFAStates(sortBy(lteSilver, list) :: states, []);	
}

function getUpdatedTransTable
[DFATransition] ::= state :: [Integer] epsClosureList:: [Integer] input :: String transTable :: [DFATransition]
{
	return if null(epsClosureList)
		then
			transTable
		else
			createDFATrans(state, epsClosureList, input) :: transTable;			
}

function createDFATrans
DFATransition ::= fromState :: [Integer] toState :: [Integer] transChar :: String
{
	local attribute dfaTransition :: DFATransition = initDFATrans(fromState, toState, transChar);
	return dfaTransition; 	
}

abstract production initDFATrans
t :: DFATransition ::= fromState :: [Integer] toState :: [Integer] transChar :: String
{
	t.DFAFromState = sortBy(lteSilver, fromState);
	t.DFAToState = sortBy(lteSilver, toState);
	t.transChar = transChar;
}

abstract production AddFinalStateToDFA
d :: DFA ::= state :: [Integer] dfa :: DFA
{
	d.dfaStartState = dfa.dfaStartState;
	d.dfaStates = dfa.dfaStates;
	d.dfaTransTable = dfa.dfaTransTable;
	d.dfaFinalStates = state :: dfa.dfaFinalStates;
	d.c = dfa.c;
	d.dfaSize = dfa.dfaSize;
	d.dfaMapper = dfa.dfaMapper;
}

abstract production UpdateDFAForNfa
n :: NFA ::= nfainput :: NFA dfa::DFA
{
	n.stateCount = nfainput.stateCount;
	n.finalStates = nfainput.finalStates;
	n.transTable = nfainput.transTable;
	n.inputs = nfainput.inputs;
	n.dfa = dfa;
}

-- MOVE FUNCTION
function move
[Integer] ::= state :: [Integer] input :: String nfa :: NFA
{
	return if null(state)
		then []
		else
			removeDups((walkTransitions (nfa.transTable, head(state), input) ++ move (tail(state), input, nfa)), []);
}

function walkTransitions
[Integer] ::= transitions :: [Transition] state :: Integer input :: String
{
	return if null(transitions)
		then []
		else
			if head(transitions).fromState == state && head(transitions).transChar == input
				then head(transitions).toState :: walkTransitions(tail(transitions), state, input)
			else
				walkTransitions(tail(transitions), state, input);
}

-- HELPER FUNCTIONS FOR DFA CONSTRUCTION

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

function removeStringDuplicate
[String] ::= list :: [String] templist :: [String]
{
	return if null(list)
	then
		templist
	else
		if (isStatePresentString(head(list), templist))
		then
			removeStringDuplicate(tail(list), templist)
		else
			removeStringDuplicate(tail(list), head(list) :: templist);
}

function removeDupDFAStates
[[Integer]] ::= list :: [[Integer]] templist :: [[Integer]]
{
	return if null(list)
		then
			templist
		else
			if (checkPresence(head(list), templist))
				then
					removeDupDFAStates(tail(list), templist)
				else
					removeDupDFAStates(tail(list), templist ++ [head(list)]);
}

function isStatePresentString
Boolean ::= state::String statelist::[String]
{
	return if null(statelist)
		then false
		else
			if state == head(statelist) 
			then true
			else
				isStatePresentString(state, tail(statelist));
}

function lteSilver
Boolean ::= value1 :: Integer value2 :: Integer
{
	return if value1 <= value2
	then
		true
	else
		false;
}

function checkPresence
Boolean ::= list :: [Integer] listOfList :: [[Integer]]
{
	return if null(listOfList)
	then
		false
	else
		if checkPresenceLevelTwo(sortBy(lteSilver, list), sortBy(lteSilver,head(listOfList)))
		then	
			true
		else
			checkPresence(list, tail(listOfList));

}

function checkPresenceLevelTwo
Boolean ::= list :: [Integer] sndList :: [Integer]
{
	return if null(list) && null(sndList)
	then
		true
	else
		if null(list) && !null(sndList)
		then
			false
		else
			if !null(list) && null(sndList)
			then 
				false
			else
				(head(list) == head(sndList)) && checkPresenceLevelTwo(tail(list), tail(sndList));
}

function removeCurrentState
[[Integer]] ::=  tempStates :: [[Integer]] states :: [[Integer]]
{
	return if null(states)
	then []
	else
		if checkPresence(head(states), tempStates) == false
		then 
			head(states) :: removeCurrentState(tempStates, tail(states))
		else
			removeCurrentState(tempStates, tail(states));
}

function populatePPForDFA
String ::= transitions :: [DFATransition]
{
	return if null(transitions)
		then
			""
		else
			getDFATransString(head(transitions)) ++ " " ++ populatePPForDFA(tail(transitions));
}
												
function getDFATransString
String ::= dfatransition :: DFATransition
{
	return "[" ++ "(" ++ getStringFromList(dfatransition.DFAFromState) ++ ")" ++ "," ++ "(" ++ getStringFromList(dfatransition.DFAToState) ++ ")" ++ "," ++ dfatransition.transChar ++ "]";
}

function getStringFromList
String ::= intlist :: [Integer]
{
	return if null(intlist)
		then 
			""
		else
			toString(head(intlist)) ++ " " ++ getStringFromList(tail(intlist));
}

------------------------------------------------------------------------------------------------------
-- C CODE GENERATION FUNCTIONS
------------------------------------------------------------------------------------------------------

function getStateCount
Integer ::=  states :: [[Integer]] num :: Integer
{
	return if null(states)
		then 
			num
		else
			getStateCount(tail(states), num + 1);
}

function getTransitionsCCode
String ::= dfatransTable :: [DFATransition] dfaMap :: [Pair<[Integer] Integer>]
{
	return if null(dfatransTable)
		then 
			""
		else
			stringFromTransition(head(dfatransTable), dfaMap) ++ getTransitionsCCode(tail(dfatransTable), dfaMap);
}

function stringFromTransition
String ::= transition :: DFATransition dfaMap :: [Pair<[Integer] Integer>]
{
	return "\tadd_trans(&dfa1," ++ toString(lookup(transition.DFAFromState, dfaMap)) ++ "," ++ toString(lookup(transition.DFAToState, dfaMap)) ++ "," ++ "'" ++ transition.transChar ++ "'" ++ ");\n";
}

function getFinalStatesCCode
String ::= finalstates :: [[Integer]] dfaMap :: [Pair<[Integer] Integer>]
{
	return if null(finalstates)
		then
			""
		else
			"\tset_final_state(&dfa1," ++ toString(lookup(head(finalstates), dfaMap)) ++ ");\n" ++ getFinalStatesCCode(tail(finalstates), dfaMap);
}

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

  -- TESTING FRAMEWORK -- 
  -- These functions were written to support testing and debugging

  -- INSTRUCTIONS:

  -- i. The following functions are to be invoked from abstract production rootREGEX
  -- ii. Move them to abstract production rootREGEX when testimg is needed

  -- 1. Testing epsclosure([0])
  -- r.pp = getStringFromList(epsTest(x.nfa, [3]));

  -- 2. Testing DFA start state
  -- r.pp = getStringFromList ((epsClosureDFAFun(x.nfa, [0])).dfaStartState);

  -- 3. Testing DFA state list
  -- r.pp = getDFAStateList ((epsClosureDFAFun(x.nfa, [0])).dfaStates);

  -- 4. Testing DFA trans table
  -- r.pp = getDFATransitionString ((epsClosureDFAFun(x.nfa, [0])).dfaTransTable);
  
  -- 5. r.pp = getDFATransitionString (testCreateDFATrans([0], [1], "a")::(epsClosureDFAFun(x.nfa, [0])).dfaTransTable);
  -- r.pp = getDFAStateList (epsClosureDFAFun());

  -- 6. Testing NFA inputs
  -- r.pp = listStringPrint(x.nfa.inputs);
  -- r.pp = head(x.nfa.inputs);

  -- 7. Testing final states
  -- r.pp = toString(x.nfa.finalStates);

  -- r.pp = listStringPrint(removeStringDuplicate(["a"], []));

  -- 8. Check whether the state is present
  -- r.pp = toString(isStatePresent(x.nfa.finalStates, [0]));

  -- 9. Test MOVE function
  -- r.pp = getStringFromList(move([1,2], "b", x.nfa));

  -- 10. Test epsilon Closure function
  -- r.pp = getStringFromList(epsClosure(x.nfa, move([0], "a", x.nfa)));

  -- 11. Test the population of dfaStates
  -- r.pp = getDFAStateList(removeDupDFAStates(epsClosure(x.nfa, move([0], "a", x.nfa)) :: [[0]], []));

  -- 12. Test removeCurrentState function
  -- r.pp = getDFAStateList(removeCurrentState([[0], [1,2]], [[1,2], [0], [3]]));

  -- 14. Some random testing
  -- r.pp = getDFAStateList(removeDupDFAStates([[3], [1,2], [0]], []));

  -- 15. Test the population of dfaStates
  -- r.pp = getDFAStateList(removeDupDFAStates([[1,2], [0], [1]], []));

  -- 16. Test mapperFunc
  -- r.pp = printListOfPairs(mapperFunc([[0,1,2,3], [4,5,6,7], [8,9,10,11], [12,13,14,15]]));

  {-
   r.pp = "\n\nNFA Start State: 0" ++ 
   "\nNFA State Count: " ++ toString(x.nfa.stateCount) ++ 
   "\nNFA Final States: " ++ toString(x.nfa.finalStates) ++ 
   "\nNFA Inputs: " ++ "[" ++ listStringPrint(x.nfa.inputs) ++ "]" ++ 
   "\nNFA Transition Table: " ++ x.pp ++ 
   "\n\nDFA Start State: " ++ getStringFromList((getDFAFromNFA(x.nfa)).dfaStartState) ++ 
   "\nDFA Final States: " ++ getDFAStateList((getDFAFromNFA(x.nfa)).dfaFinalStates) ++ 
   "\nDFA States: " ++ "[" ++ getDFAStateList((getDFAFromNFA(x.nfa)).dfaStates) ++ "]" ++ 
   "\nDFA Transition Table: \n" ++ "[" ++ populatePPForDFA((getDFAFromNFA(x.nfa)).dfaTransTable) ++ "]\n";
   -}
  
  -- TESTING FRAMEWORK END

  -- FUNCTIONS WRITTEN TO SUPPORT TESTING AND DEBUGGING

function listStringPrint
String ::= list :: [String]
{
	return if null(list)
	then
		""
	else
		 head(list) ++ " " ++ listStringPrint(tail(list));	
}

function epsTest
[Integer] ::= nfa :: NFA t :: [Integer]
{
	return epsClosure(nfa, t);	
}

function getDFAStateList
String ::= list :: [[Integer]]
{
	return if null(list)
		then
			""
		else
			getStringFromList(head(list)) ++ ", " ++ getDFAStateList(tail(list));
}

function getDFATransitionString
String ::= list :: [DFATransition]
{
	return if null(list)
		then
			""
		else
			getTransString(head(list)) ++ getDFATransitionString(tail(list));
}

function getTransString
String ::= transition :: DFATransition
{
	return "(" ++ getStringFromList(transition.DFAFromState) ++ "," ++ getStringFromList(transition.DFAToState) ++ "," ++ transition.transChar;
}

abstract production testCreateDFATrans
d :: DFATransition ::= fromState :: [Integer] toState :: [Integer] trans :: String 
{	
  	d.DFAFromState = fromState;
  	d.DFAToState = toState;
  	d.transChar = trans;
}

function mapperFunc
[Pair<[Integer] Integer>] ::= stateList :: [[Integer]] counter :: Integer
{
	return if null(stateList)
	then
		[]
	else
		pair(head(stateList), counter) :: mapperFunc(tail(stateList), counter+1);
}

function printListOfPairs
String ::= list :: [Pair<[Integer] Integer>]
{
	return if null(list)
		then
			""
		else
			getPairString(head(list)) ++ printListOfPairs(tail(list));
}

function getPairString
String ::= pair :: Pair<[Integer] Integer>
{
	return "[" ++ getStringFromList(pair.fst) ++ "->" ++ toString(pair.snd) ++ "]\n";
}

function lookup
Integer ::= stateList :: [Integer] dictionary :: [Pair<[Integer] Integer>]
{
	return if null(dictionary)
	then 
		-1
	else
		if checkPresenceLevelTwo(stateList, head(dictionary).fst)
		then 
			head(dictionary).snd
		else 
			lookup(stateList, tail(dictionary));
}

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------