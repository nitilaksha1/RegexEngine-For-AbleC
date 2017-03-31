marking terminal RegexBegin_t '/';
terminal RegexEnd_t '/';

synthesized attribute regString :: String;

lexer class REGEX_OPER;
lexer class REGEX_ESC submits to REGEX_OPER;

terminal Kleene_t        '*' lexer classes { REGEX_OPER };
terminal Choice_t        '|' lexer classes { REGEX_OPER };
terminal RegexLParen_t   '(' lexer classes { REGEX_OPER };
terminal RegexRParen_t   ')' lexer classes { REGEX_OPER };
terminal RegexChar_t     /./ lexer classes { REGEX_ESC }, submits to { cnc:Divide_t };

nonterminal Regex_CHAR with regString;
nonterminal Regex_RE with regString;     
nonterminal Regex_C with regString;      
nonterminal Regex_B with regString;    
nonterminal Regex_Sim with regString;
nonterminal Regex_CHAR with regString;


concrete production regex_c
e::cnc:PrimaryExpr_c ::= d1::RegexBegin_t  re::Regex_RE  d2::RegexEnd_t
layout {}
{
  e.ast = regexLiteralExpr("\"" ++ re.regString ++ "\"", location=e.location);
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
  re.regString = c.regString;
}

concrete production REtoRE_bar_C
re::Regex_RE ::= first::Regex_RE sep::Choice_t rest::Regex_C
layout {}
{
  re.regString = first.regString ++ "|" ++ rest.regString;
}

concrete production CtoB
c::Regex_C ::= b::Regex_B
layout {}
{
  c.regString = b.regString;
}

concrete production CconcatenateB
c::Regex_C ::= first::Regex_C rest::Regex_B
layout {}
{
  c.regString = first.regString ++ rest.regString;
}

concrete production BtoSim
b::Regex_B ::= sim::Regex_Sim
layout {}
{
  b.regString = sim.regString;
}

concrete production BtoB_star
b::Regex_B ::= first::Regex_B sep::Kleene_t
layout {}
{
  b.regString = first.regString ++ "*"; 
}

concrete production BtoLP_RE_RP
b::Regex_B ::= lp::RegexLParen_t re::Regex_RE rp::RegexRParen_t
layout {}
{
  b.regString = "(" ++ re.regString ++ ")";
}

abstract production SimtoCHAR
sim::Regex_Sim ::= char::Regex_CHAR
layout {}
{
  sim.regString = char.regString;
}

concrete production Simtoeps
sim::Regex_Sim ::=
layout {}
{
  sim.regString = "";
}

concrete production CHARtochar
top::Regex_CHAR ::= char::RegexChar_t
layout {}
{
  top.regString = char.lexeme;
}
