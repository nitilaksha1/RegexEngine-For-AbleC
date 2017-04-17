-- Current status:
-- 1) Conversion from REGEX to NFA to DFA is successful
-- 2) Concrete syntax is not integrated with ableC ecosystem

-- TO DO:
-- 1) Declare a new type in ableC called regex
-- 2) Add the regex engine to ableC ecosystem

grammar edu:umn:cs:melt:exts:ableC:regex:src:concretesyntax;

imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports silver:langutil only ast;
imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:exts:ableC:regex:src:abstractsyntax;

lexer class REGEX_OPER;
lexer class REGEX_ESC submits to REGEX_OPER;

marking terminal RegexBegin_t '/';
marking terminal Regex_t 'regex';
terminal RegexEnd_t '/';
terminal Kleene_t        '*' lexer classes { REGEX_OPER };
terminal Choice_t        '|' lexer classes { REGEX_OPER };
terminal RegexLParen_t   '(' lexer classes { REGEX_OPER };
terminal RegexRParen_t   ')' lexer classes { REGEX_OPER };
terminal RegexWildcard_t '.' lexer classes { REGEX_OPER };
terminal RegexChar_t     /./ lexer classes { REGEX_ESC }, submits to { cnc:Divide_t };
terminal EscapedChar_t /\\./ submits to { REGEX_ESC };

nonterminal Root_c with root, pp;
nonterminal Regex_RE with ast_REGEX, pp;     
nonterminal Regex_C with ast_REGEX, pp;      
nonterminal Regex_B with ast_REGEX, pp;    
nonterminal Regex_Sim with ast_REGEX, pp;
nonterminal Regex_CHAR with ast_REGEX, pp;

synthesized attribute pp :: String;
synthesized attribute root :: ROOT;
synthesized attribute ast_REGEX :: REGEX;

concrete production regexp
e :: Root_c ::= 'regex' d1 :: RegexBegin_t re::Regex_RE d2::RegexEnd_t ';'
layout {}
{
  e.root = rootREGEX(re.ast_REGEX);
}

{- 
concrete production regex_c
e::cnc:PrimaryExpr_c ::= d1::RegexBegin_t  re::Regex_RE  d2::RegexEnd_t
layout {}
{
	e.root = createDFA(re.ast_REGEX);
  e.ast = createDFA(re.ast_REGEX);
  e.ast = printNFA(re.ast_REGEX);
  e.ast = printString("Lalalalalala", location=e.location);
}
-}

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

concrete production SimtoCHAR
sim::Regex_Sim ::= char::Regex_CHAR
layout {}
{
  sim.ast_REGEX = char.ast_REGEX;
}

concrete production CHARtochar
top::Regex_CHAR ::= char:: RegexChar_t
layout {}
{
  top.ast_REGEX = NewNfa(char.lexeme);
}