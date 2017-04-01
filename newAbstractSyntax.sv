
nonterminal Nfa with statecount, finalstates, transtable;
nonterminal Transition;
synthesized attribute statecount :: Integer;
synthesized attribute finalstates :: [Integer];
synthesized attribute transtable :: [Transition];
attribute fromstate::Integer;
attribute tostate::Integer;
attribute transchar::RegexChar_t;
attribute fromstate occurs on Transition;
attribute tostate occurs on Transition;
attribute transchar occurs on Transition;

abstract production AlternationOp
e::Nfa ::= l::Nfa r::Nfa
{
	e.statecount = l.statecount + r.statecount + 2;

	local attribute transition::Transition;
	transition.fromstate = 0;
	transition.tostate = 1;
	
	--FIGURE OUT A EPISLON CHARACTER TO REPRESENT IN SILVER
	transition.transchar = '^';

	e.transtable = transition::e.transtable;

	--APPEND TRANSITIONS OF LEFT CHILD NFA TO THE RESULTANT TRANSITION TABLE
	e.transtable = e.transtable ++ addToTransTable(l.transtable, 1);

	--APPEND INTERMEDIATE FINAL STATE OF LEFT NFA TO RESULTANT FINAL STATE
	transition.fromstate = l.statecount;
	transition.tostate = e.statecount - 1;
	transition.transchar = '^';

	e.transtable = transition::e.transtable;

	--AGAIN FIGURE OUT A CHARACTER TO REPRESENT THIS EPSILON TRANSITION
	transition.fromstate = 0;
	transition.tostate = l.statecount + 1;
	transition.transchar = '^';

	e.transtable = transition::e.transtable;

	--APPEND TRANSITIONS OF RIGHT CHILD NFA TO THE RESULTANT TRANSITION TABLE
	e.transtable = e.transtable ++ addToTransTable(r.transtable, 1 + l.statecount);

	--APPEND INTERMEDIATE FINAL STATE OF RIGHT NFA TO RESULTANT FINAL STATE
	transition.fromstate = l.statecount + r.statecount;
	transition.tostate = e.statecount - 1;
	transition.transchar = '^';

	e.transtable = transition::e.transtable;

	e.finalstates = (e.statecount - 1) :: e.finalstates; 

}

abstract production KleeneOp
e::Nfa ::= param::Nfa
{
	e.statecount = param.statecount + 2;

	local attribute transition::Transition;

	--EPSILON TRANSITION TO START NODE OF THE CHILD NFA
	transition.fromstate = 0;
	transition.tostate = 1;
	transition.transchar = '^';

	e.transtable = transition::e.transtable;

	--APPEND TRANSITION OF THE CHILD NFA TO THE RESULTANT NFA
	e.transtable = e.transtable ++ addToTransTable(param.transtable, 1);

	--ANOTHER EPSILON TRANSITION CONNECTING TO THE END
	transition.fromstate = param.statecount;
	transition.tostate = param.statecount + 1;
	transition.transchar = '^';

	e.transtable = transition::e.transtable;

	--ANOTHER EPSILON TRANSITION CONNECTING TO THE END
	transition.fromstate = param.statecount;
	transition.tostate = 1;
	transition.transchar = '^';

	e.transtable = transition::e.transtable;

	--ANOTHER EPSILON TRANSITION CONNECTING TO THE END
	transition.fromstate = 0;
	transition.tostate = param.statecount + 1;
	transition.transchar = '^';

	e.finalstates = (e.statecount + 1) :: e.finalstates;
}

abstract production ConcatOp
e::Nfa ::= l::Nfa r::Nfa
{
	e.statecount = l.statecount + r.statecount;
	
	--APPEND TRANSITION OF LEFTCHILD NFA TO THE RESULTANT NFA
	e.transtable = e.transtable ++ addToTransTable(l.transtable, 0);

	local attribute transition::Transition;

	--CONNECT FINAL STATES OF LEFT NFA TO START NODE OF RIGHT NFA USING AN EPSILON TRANSITION AND POPULATE RESULTANT TABLE
	--e.transtable = e.transtable ++ finalStateConnectionForConcat(l.finalstates, l.statecount, '^');
	
	transition.fromstate = l.statecount - 1;
	transition.tostate = l.statecount;
	transition.transchar = '^';

	--APPEND TRANSITIONS OF RIGHT CHILD NFA TO THE RESULTANT NFA
	e.transtable = e.transtable ++ addToTransTable(r.transtable, l.statecount);

	e.finalstates = (l.statecount + r.statecount - 1) :: e.finalstates;
}


function addToTransTable
[Transition] ::= transitions::[Transition] offset::Integer
{
	  return if null(transitions)
			then []
			else
				local attribute transition::Transition = head(transitions);
				transition.fromstate = transition.fromstate + offset;
				transition.tostate = transtion. tostate + offset;
				transition :: addToTransTable(tail(transitions), offset);	
}

function finalStateConnectionForConcat
[Transition] ::= finalstates::[Integer] tostate::Integer transchar::RegexChar_t 
{
	return if null(finalstates)
		then []
		else
			local attribute transition::Transition;
			transition.fromstate = head(finalstates);
			transition.tostate = tostate;
			transition.transchar = transchar;
			transition :: finalStateConnectionForConcat(tail(finalstates), tostate, transchar);		
}

{--
function setFinalStatesForConcat
[Integer] ::= finalstates::[Integer] offset::Integer
{
	return if null(finalstates)
		then []
		else
			(head(finalstates) + offset) :: setFinalStatesForConcat(tail(finalstates), offset);
}
--}
