marking terminal RegexBegin_t '/';
terminal RegexEnd_t '/';

lexer class REGEX_OPER;
lexer class REGEX_ESC submits to REGEX_OPER;

terminal Kleene_t        '*' lexer classes { REGEX_OPER };
terminal Choice_t        '|' lexer classes { REGEX_OPER };
terminal RegexLParen_t   '(' lexer classes { REGEX_OPER };
terminal RegexRParen_t   ')' lexer classes { REGEX_OPER };
terminal RegexChar_t     /./ lexer classes { REGEX_ESC }, submits to { cnc:Divide_t };

nonterminal Root_c with pp, root;

nonterminal Regex_RE with ast_REGEX;     
nonterminal Regex_C with ast_REGEX;      
nonterminal Regex_B with ast_REGEX;    
nonterminal Regex_Sim with ast_REGEX;
nonterminal Regex_CHAR with ast_REGEX;

synthesized attribute ast_REGEX :: REGEX ;
synthesized attribute root :: ROOT ;

concrete production regex_c
-- Some changes might be needed here
e::cnc:PrimaryExpr_c ::= d1::RegexBegin_t  re::Regex_RE  d2::RegexEnd_t
layout {}
{
	e.root = createDFA(re.ast_REGEX);
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
  re.ast_REGEX = c.ast_REGEX;
}

concrete production REtoRE_bar_C
re::Regex_RE ::= first::Regex_RE sep::Choice_t rest::Regex_C
layout {}
{
  re.ast_REGEX = AlternationOp(first.ast_REGEX, rest.ast_REGEX);
}

concrete production CtoB
c::Regex_C ::= b::Regex_B
layout {}
{
  c.ast_REGEX = b.ast_REGEX;
}

concrete production CconcatenateB
c::Regex_C ::= first::Regex_C rest::Regex_B
layout {}
{
  c.ast_REGEX = ConcatOp(first.ast_REGEX, rest.ast_REGEX);
}

concrete production BtoSim
b::Regex_B ::= sim::Regex_Sim
layout {}
{
  b.ast_REGEX = sim.ast_REGEX;
}

concrete production BtoB_star
b::Regex_B ::= first::Regex_B sep::Kleene_t
layout {}
{
  b.ast_REGEX = KleeneOp(first.ast_REGEX);
}

concrete production BtoLP_RE_RP
b::Regex_B ::= lp::RegexLParen_t re::Regex_RE rp::RegexRParen_t
layout {}
{
  b.ast_REGEX = re.ast_REGEX;
}

abstract production SimtoCHAR
sim::Regex_Sim ::= char::Regex_CHAR
layout {}
{
  sim.ast_REGEX = char.ast_REGEX;
}

concrete production Simtoeps
sim::Regex_Sim ::=
layout {}
{
  sim.ast_REGEX = NewEpsilonTrans();
}

concrete production CHARtochar
top::Regex_CHAR ::= char::RegexChar_t
layout {}
{
  top.ast_REGEX = NewNfa(char.lexeme);
}
