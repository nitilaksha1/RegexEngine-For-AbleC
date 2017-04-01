marking terminal RegexBegin_t '/';
terminal RegexEnd_t '/';

lexer class REGEX_OPER;
lexer class REGEX_ESC submits to REGEX_OPER;

terminal Kleene_t        '*' lexer classes { REGEX_OPER };
terminal Choice_t        '|' lexer classes { REGEX_OPER };
terminal RegexLParen_t   '(' lexer classes { REGEX_OPER };
terminal RegexRParen_t   ')' lexer classes { REGEX_OPER };
terminal RegexChar_t     /./ lexer classes { REGEX_ESC }, submits to { cnc:Divide_t };

nonterminal Regex_RE with nfa;     
nonterminal Regex_C with nfa;      
nonterminal Regex_B with nfa;    
nonterminal Regex_Sim with nfa;
nonterminal Regex_CHAR with nfa;

synthesized attribute nfa :: Nfa
nonterminal Nfa with statecount, finalstates, transtable;
nonterminal Transition;
synthesized attribute statecount :: Integer;
synthesized attribute finalstates :: [Integer];
synthesized attribute transtable :: [Transition];
attribute fromstate occurs on Transition;
attribute tostate occurs on Transition;
attribute transchar occurs on Transition;

concrete production regex_c
e::cnc:PrimaryExpr_c ::= d1::RegexBegin_t  re::Regex_RE  d2::RegexEnd_t
layout {}
{
  --e.ast = regexLiteralExpr("\"" ++ re.regString ++ "\"", location=e.location);
	e.dfa = createDFA(re.nfa);
}

abstract production literalRegex
re::Regex_RE ::= s::String
{
  re.regString = regexPurifyString(s);
}

function regexPurifyString
String ::= s::String
{
  local attribute ch :: String;
  ch = substring(0, 1, s);

  local attribute rest :: String;
  rest = substring(1, length(s), s);

  return if length(s) == 0 
	 then ""
	 else if isAlpha(ch) || isDigit(ch)
	      then ch ++ regexPurifyString(rest)
	      else "[\\" ++ ch ++ "]" ++ regexPurifyString(rest);
}

concrete production REtoC
re::Regex_RE ::= c::Regex_C
layout {}
{
  re.nfa = c.nfa;
}

concrete production REtoRE_bar_C
re::Regex_RE ::= first::Regex_RE sep::Choice_t rest::Regex_C
layout {}
{
  re.nfa = AlternationOp(first.nfa, rest.nfa);
}

concrete production CtoB
c::Regex_C ::= b::Regex_B
layout {}
{
  c.nfa = b.nfa;
}

concrete production CconcatenateB
c::Regex_C ::= first::Regex_C rest::Regex_B
layout {}
{
  c.nfa = ConcatOp(first.nfa, rest.nfa);
}

concrete production BtoSim
b::Regex_B ::= sim::Regex_Sim
layout {}
{
  b.nfa = sim.nfa;
}

concrete production BtoB_star
b::Regex_B ::= first::Regex_B sep::Kleene_t
layout {}
{
  b.nfa = KleeneOp(first.nfa);
}

concrete production BtoLP_RE_RP
b::Regex_B ::= lp::RegexLParen_t re::Regex_RE rp::RegexRParen_t
layout {}
{
  b.nfa = re.nfa;
}

abstract production SimtoCHAR
sim::Regex_Sim ::= char::Regex_CHAR
layout {}
{
  sim.nfa = char.nfa;
}

concrete production Simtoeps
sim::Regex_Sim ::=
layout {}
{
  sim.nfa = NewEpsilonTrans();
}

concrete production CHARtochar
top::Regex_CHAR ::= char::RegexChar_t
layout {}
{
  top.nfa = NewNfa(char.lexeme);
}
